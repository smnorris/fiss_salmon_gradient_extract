
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
  (pr.upstream_elevation - pr.downstream_elevation) / (pr.upstream_route_measure - pr.downstream_route_measure) as gradient,
  (pr.upstream_route_measure - pr.downstream_route_measure) as length
from temp.salmon_observation_points pt
inner join whse_basemapping.fwa_stream_networks_sp s
on fwa_downstream(
pt.blue_line_key,
pt.downstream_route_measure,
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
  pr.segment_id,
  pr.downstream_route_measure,
  pr.upstream_route_measure,
  pr.downstream_elevation,
  pr.upstream_elevation,
  (pr.upstream_elevation - pr.downstream_elevation) / (pr.upstream_route_measure - pr.downstream_route_measure) as gradient,
  (pr.upstream_route_measure - pr.downstream_route_measure) as length
from pt 
inner join whse_basemapping.fwa_stream_profiles pr
on pt.blue_line_key = pr.blue_line_key
and pt.downstream_route_measure > pr.downstream_route_measure
)


select distinct on (observation_key)
  observation_key,
  blue_line_key,
  downstream_route_measure,
  upstream_route_measure,
  downstream_elevation,
  upstream_elevation,
  round(gradient::numeric, 2) as gradient,
  round(length::numeric, 2) as length
from grade_dnstr
order by observation_key, gradient desc