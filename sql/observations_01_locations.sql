-- for convenience, create table holding subset of observation locations - all distinct salmon/steelhead observation locations

create schema if not exists temp;
drop table if exists temp.observation_locations;

create table temp.observation_locations as
select 
  blue_line_key,
  downstream_route_measure as measure,
  linear_feature_id,
  wscode,
  localcode,
  array_agg(observation_key) as observation_keys
from bcfishobs.observations
where species_code in ('CH','CM','CO','PK','SK','ST')
group by blue_line_key, downstream_route_measure, linear_feature_id, wscode, localcode;

create index on temp.observation_locations (blue_line_key, measure);
create index on temp.observation_locations (linear_feature_id);
create index on temp.observation_locations (wscode);
create index on temp.observation_locations (localcode);
create index on temp.observation_locations using gist (wscode);
create index on temp.observation_locations using gist (localcode);
