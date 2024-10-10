with at_site as (
  select
    e.stream_sample_site_id,
    e.blue_line_key,
    e.downstream_route_measure as measure,
    pr.downstream_route_measure,
    pr.upstream_route_measure,
    pr.segment_id,
    pr.downstream_elevation as downstream_elevation,
    (pr.upstream_elevation - pr.downstream_elevation) / (pr.upstream_route_measure - pr.downstream_route_measure) as gradient,
    (pr.upstream_route_measure - pr.downstream_route_measure) as gradient_length
  from fiss_stream_sample_sites e
  inner join whse_basemapping.fwa_stream_profiles pr
  on e.blue_line_key = pr.blue_line_key 
  and round(e.downstream_route_measure::numeric, 2) >= pr.downstream_route_measure
  and round(e.downstream_route_measure::numeric, 2) < pr.upstream_route_measure
  order by stream_sample_site_id
),

upstr as (
  select
    e.stream_sample_site_id,
    e.blue_line_key,
    pr.segment_id,
    (pr.upstream_elevation - pr.downstream_elevation) / (pr.upstream_route_measure - pr.downstream_route_measure) as gradient,
    (pr.upstream_route_measure - pr.downstream_route_measure) as gradient_length
  from at_site e
  inner join whse_basemapping.fwa_stream_profiles pr
  on e.blue_line_key = pr.blue_line_key 
  and e.segment_id + 1 = pr.segment_id
  order by stream_sample_site_id
),

dnstr as (
  select
    e.stream_sample_site_id,
    e.blue_line_key,
    pr.segment_id,
    (pr.upstream_elevation - pr.downstream_elevation) / COALESCE(NULLIF((pr.upstream_route_measure - pr.downstream_route_measure),0), 1)  as gradient,
    (pr.upstream_route_measure - pr.downstream_route_measure) as gradient_length
  from at_site e
  inner join whse_basemapping.fwa_stream_profiles pr
  on e.blue_line_key = pr.blue_line_key 
  and e.segment_id - 1 = pr.segment_id
  order by stream_sample_site_id
),

nearest_vertex as (
  select distinct on (stream_sample_site_id)
    stream_sample_site_id, 
    diff,
    blue_line_key,
    segment_id,
    measure,
    elevation
  from (
    -- calculate distance to each endpoint
    select 
      stream_sample_site_id, 
      segment_id,
      blue_line_key,
      downstream_route_measure as measure, 
      downstream_elevation as elevation,
      abs(measure - downstream_route_measure) as diff

    from at_site
    union all
    select 
      stream_sample_site_id, 
      segment_id,
      blue_line_key,
      upstream_route_measure as measure, 
      downstream_elevation as elevation,
      abs(upstream_route_measure - measure) as diff 
    from at_site 
  ) as measures
  order by stream_sample_site_id, diff asc
),

adjacent_vertex as (
  select 
    pt.stream_sample_site_id,
    pt.segment_id,
    dn_pt.downstream_route_measure as measure_ds, 
    dn_pt.downstream_elevation as elevation_ds, 
    up_pt.downstream_route_measure as measure_us, 
    up_pt.downstream_elevation as elevation_us
  from nearest_vertex pt
  left outer join whse_basemapping.fwa_stream_profiles dn_pt on pt.blue_line_key = dn_pt.blue_line_key
  and dn_pt.segment_id = pt.segment_id - 1
  left outer join whse_basemapping.fwa_stream_profiles up_pt on pt.blue_line_key = up_pt.blue_line_key
  and up_pt.segment_id = pt.segment_id + 1
)

select
  pt.stream_sample_site_id,
  pt.blue_line_key,
  pt.downstream_route_measure,
  pt.distance_to_stream,
  src.wbody_id,
  src.data_source,
  src.field_utm_zone,
  src.field_utm_easting,
  src.field_utm_northing,
  src.gis_utm_zone,
  src.gis_utm_easting,
  src.gis_utm_northing,
  src.gradient as surveyed_gradient,
  src.surveyed_length,
  src.channel_width,
  src.pool_depth,
  src.bed_morphology,
  null as field_gis_utm_match,
  s.wscode_ltree as wscode,
  s.stream_order,
  s.edge_type,
  round((a.gradient * 100)::numeric, 2) as gradient,
  round(a.gradient_length::numeric, 2) as gradient_length,
  round((b.gradient * 100)::numeric, 2) as gradient_upstr,
  round(b.gradient_length::numeric, 2) as gradient_upstr_length,
  round((c.gradient * 100)::numeric, 2) as gradient_dnstr,
  round(c.gradient_length::numeric, 2) as gradient_dnstr_length,
  --ROUND((ST_Z((ST_Dump((ST_LocateAlong(s.geom, nv.measure)))).geom))::numeric, 2) as elevation_v,
  --ROUND((ST_Z((ST_Dump((ST_LocateAlong(s2.geom, nv.measure + 100)))).geom))::numeric, 2) as elevation_v100,
  --round(((ST_Z((ST_Dump((ST_LocateAlong(s2.geom, nv.measure + 100)))).geom) - ST_Z((ST_Dump((ST_LocateAlong(s.geom, nv.measure)))).geom)) )::numeric, 2) as gradient100m,
  round((ST_Z((ST_Dump((ST_LocateAlong(s2.geom, nv.measure + 100)))).geom) - nv.elevation)::numeric, 2) as gradient100m,
  round((ST_Z((ST_Dump((ST_LocateAlong(s2.geom, av.measure_us + 100)))).geom) - av.elevation_us)::numeric, 2) as gradient100m_upstream,
  round((ST_Z((ST_Dump((ST_LocateAlong(s2.geom, av.measure_ds + 100)))).geom) - av.elevation_ds)::numeric, 2) as gradient100m_downstream
from fiss_stream_sample_sites pt 
inner join whse_fish.fiss_stream_sample_sites_sp src on pt.stream_sample_site_id = src.stream_sample_site_id
inner join whse_basemapping.fwa_stream_networks_sp s on pt.linear_feature_id = s.linear_feature_id
left outer join whse_basemapping.fwa_stream_networks_sp s2 on pt.blue_line_key = s2.blue_line_key
  and round(pt.downstream_route_measure::numeric + 100, 2) >= round(s2.downstream_route_measure::numeric, 2)
  and round(pt.downstream_route_measure::numeric + 100, 2) < round(s2.upstream_route_measure::numeric, 2)
inner join at_site a on pt.stream_sample_site_id = a.stream_sample_site_id
inner join upstr b on pt.stream_sample_site_id = b.stream_sample_site_id
inner join dnstr c on pt.stream_sample_site_id = c.stream_sample_site_id
inner join nearest_vertex nv on pt.stream_sample_site_id = nv.stream_sample_site_id
left outer join adjacent_vertex av on pt.stream_sample_site_id = av.stream_sample_site_id
order by pt.stream_sample_site_id;



