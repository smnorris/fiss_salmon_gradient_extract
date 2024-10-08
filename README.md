# Stream gradient extract at FISS locations for salmon habitat working group


## Table 1 - FISS Sample Sites

| source            | column                      | notes                         |
|-------------------|-----------------------------|-------------------------------|
| FISS sample sites | stream_sample_site_id       |                               
| FWA streams       | blue_line_key               |                               
| FWA streams       | downstream_route_measure    |                               
| FISS stream sites | water_body_id               |                               
| FISS stream sites | data_source                 |                               
| FISS stream sites | field_utm_zone              |                               
| FISS stream sites | field_utm_easting           |                               
| FISS stream sites | field_utm_northing          |                               
| FISS stream sites | gis_utm_zone                |                               
| FISS stream sites | gis_utm_easting             |                               
| FISS stream sites | gis_utm_northing            |                               
| FISS stream sites | surveyed_gradient           |                               
| FISS stream sites | surveyed_length             |                               
| FISS stream sites | channel_width               |                               
| FISS stream sites | pool_depth                  |                               
| FISS stream sites | bed_morphology              |                               
| ?                 | field_gis_utm_match         | Similar criteria to Fish OBS matching? Would need category for “no Field UTM recorded” |
| FWA streams       | watershed_code              |                               
| FWA streams       | stream_order                | 
| FWA streams       | gradient                    | Stream gradient (%) at location on which the point falls.
| FWA streams       | gradient_length             | Distance between stream vertices at location on which the point falls.
| FWA streams       | gradient_upstream           | Gradient of the adjacent upstream segment
| FWA streams       | gradient_upstream_length    | Distance between adjacent stream vertices, upstream
| FWA streams       | gradient_downstream         | Gradient of the adjacent downstream segment
| FWA streams       | gradient_downstream_length  | Distance between adjacent stream vertices, downstream
| FWA streams       | gradient100m                | Gradient from vertex nearest to survey site to 100m upstream of that vertex
| FWA streams       | gradient100m_upstream       | Gradient from adjacent upstream vertex (relative to vertex nearest to survey site), to 100m upstream of that vertex
| FWA streams       | gradient100m_downstream     | Gradient from adjacent downstream vertex (relative to vertex nearest to survey site), to 100m upstream of that vertex


## Table 2 - FISS Observations

| source            | column               | notes                         |
|-------------------|----------------------|-------------------------------|
| FISS observations | source               | 
| FISS observations | species_code         | 
| FISS observations | observation_date     | 
| FISS observations | utm_zone             | 
| FISS observations | utm_easting          | 
| FISS observations | utm_northing         | 
| FISS observations | life_stage_code      |
| FWA streams       | watershed_code       | 
| FWA streams       | blue_line_key        | 
| FWA streams       | stream_order         | 
| FWA streams       | max_gradient_ds      | Maximum gradient downstream of the observation
| FWA streams       | max_gradient100m_ds  | Maximum 100m gradient downstream of the observation
| FWA streams       | migration_dist_total | Distance from ocean to observation
| FWA streams       | migration_dist_lt05  | Distance migrated at gradients <=5%
| FWA streams       | migration_dist_05_10 | Distance migrated at gradients >5 to <=10%
| FWA streams       | migration_dist_10_15 | Distance migrated at gradients >10 to <=15%
| FWA streams       | migration_dist_15_20 | Distance migrated at gradients >15 to <=20%
| FWA streams       | migration_dist_20_25 | Distance migrated at gradients >20 to <=25%
| FWA streams       | migration_dist_25_30 | Distance migrated at gradients >25 to <=30%
| FWA streams       | migration_dist_gt30  | Distance migrated at gradients >30%
