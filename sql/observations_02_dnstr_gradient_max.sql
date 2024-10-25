create table temp.observations_dnstr_gradient_max as

with grade_dnstr as (
select 
  pt.blue_line_key,
  pt.measure,
  pr.blue_line_key as seg_blkey,
  pr.segment_id,
  pr.downstream_route_measure,
  pr.upstream_route_measure,
  pr.downstream_elevation,
  pr.upstream_elevation,
  (pr.upstream_elevation - pr.downstream_elevation) / COALESCE(NULLIF((pr.upstream_route_measure - pr.downstream_route_measure),0), 1) as gradient,
  (pr.upstream_route_measure - pr.downstream_route_measure) as length
from temp.observation_locations pt
inner join whse_basemapping.fwa_stream_networks_sp s
on fwa_downstream(
pt.blue_line_key,
pt.measure,
pt.wscode,
pt.localcode,
s.blue_line_key,
s.downstream_route_measure,
s.wscode_ltree,
s.localcode_ltree
) and pt.blue_line_key != s.blue_line_key -- include equivalent blkey matches below
inner join whse_basemapping.fwa_stream_profiles pr
on s.linear_feature_id = pr.linear_feature_id

union all

select
  pt.blue_line_key,
  pt.measure,
  pr.blue_line_key as seg_blkey,
  pr.segment_id,
  pr.downstream_route_measure,
  pr.upstream_route_measure,
  pr.downstream_elevation,
  pr.upstream_elevation,
  (pr.upstream_elevation - pr.downstream_elevation) / COALESCE(NULLIF((pr.upstream_route_measure - pr.downstream_route_measure),0), 1) as gradient,
  (pr.upstream_route_measure - pr.downstream_route_measure) as length
from temp.observation_locations pt
inner join whse_basemapping.fwa_stream_profiles pr
on pt.blue_line_key = pr.blue_line_key
and pt.measure > pr.downstream_route_measure
)

-- find max gradient by selecting distinct locations and sorting by gradient,
-- (rather than using max(), this retains the additional attributes useful for QA)

select distinct on (blue_line_key, measure)
  blue_line_key,
  measure,
  upstream_route_measure,
  downstream_elevation,
  upstream_elevation,
  round(gradient::numeric, 2) as gradient,
  round(length::numeric, 2) as length
from grade_dnstr
order by blue_line_key, measure, gradient desc;

create index on temp.observations_dnstr_gradient_max (blue_line_key, measure);