#!/bin/bash

set -euxo pipefail

PSQL="psql $DATABASE_URL -v ON_ERROR_STOP=1"
WSGS=$($PSQL -AXt -c "SELECT watershed_group_code FROM whse_basemapping.fwa_watershed_groups_poly")

# download sample sites, snap to streams, report on gradients
bcdata bc2pg WHSE_FISH.FISS_STREAM_SAMPLE_SITES_SP
$PSQL -f sql/stream_sample_sites_01_snap.sql
$PSQL -f sql/stream_sample_sites_02_gradient.sql --csv > stream_sample_sites_gradient.csv

# download observations, snap to streams
git clone https://github.com/smnorris/bcfishobs.git
cd bcfishobs
./process.sh
cd ..

# create gradient barriers table and download query to generate them
$PSQL -c "CREATE SCHEMA IF NOT EXISTS bcfishpass;
CREATE TABLE bcfishpass.gradient_barriers (
 gradient_barrier_id bigint GENERATED ALWAYS AS ((((blue_line_key::bigint + 1) - 354087611) * 10000000) + round(downstream_route_measure::bigint)) STORED PRIMARY KEY,
 blue_line_key             integer               ,
 downstream_route_measure  double precision      ,
 wscode_ltree              ltree                 ,
 localcode_ltree           ltree                 ,
 watershed_group_code      character varying(4)  ,
 gradient_class            integer
 );

create index grdntbr_blk_idx on bcfishpass.gradient_barriers (blue_line_key);
create index grdntbr_wsgcode_idx on bcfishpass.gradient_barriers (watershed_group_code);
create index grdntbr_wscode_gidx on bcfishpass.gradient_barriers using gist (wscode_ltree);
create index grdntbr_wscode_bidx on bcfishpass.gradient_barriers using btree (wscode_ltree);
create index grdntbr_localcode_gidx on bcfishpass.gradient_barriers using gist (localcode_ltree);
create index grdntbr_localcode_bidx on bcfishpass.gradient_barriers using btree (localcode_ltree);
"
curl https://raw.githubusercontent.com/smnorris/bcfishpass/refs/heads/main/model/01_access/gradient_barriers/sql/gradient_barriers_load.sql -o sql/gradient_barriers_load.sql

parallel $PSQL -f sql/gradient_barriers_load.sql -v wsg={1} ::: $WSGS

# run queries
$PSQL -c "select
 blue_line_key,
 downstream_route_measure as measure,
 watershed_group_code,
 round(distance_to_stream::numeric, 2) as distance_to_stream,
 observation_key,
 wbody_id,
 species_code,
 agency_id,
 point_type_code,
 observation_date,
 agency_name,
 source,
 source_ref,
 utm_zone,
 utm_easting,
 utm_northing,
 activity_code,
 activity,
 life_stage_code,
 life_stage,
 species_name,
 waterbody_identifier,
 waterbody_type,
 gazetted_name,
 new_watershed_code,
 trimmed_watershed_code,
 acat_report_url,
 feature_code
from bcfishobs.observations
where species_code in ('CH','CM','CO','PK','SK','ST')" --csv > observations.csv

time $PSQL -f sql/observations_01_locations.sql
time $PSQL -f sql/observations_02_dnstr_gradient_max.sql
time $PSQL -f sql/observations_03_dnstr_gradient100_max.sql
time $PSQL -c "select
  a.blue_line_key,
  a.measure,
  a.gradient as dnstr_gradient_max,
  a.length as dnstr_gradient_max_length,
  b.gradient_class as dnstr_gradient100class_max
from temp.observations_dnstr_gradient_max a
left outer join temp.observations_dnstr_gradient100_max b
on a.blue_line_key = b.blue_line_key and a.measure = b.measure;" --csv > observations_dnstr_gradient_max.csv

# this needs to be looped over per observation location
#time $PSQL -f sql/observations_04_dnstr_gradient_classes.sql --csv > observations_dnstr_gradient_classes.csv