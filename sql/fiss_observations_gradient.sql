select
  v.source,
  v.species_code,
  v.observation_date,
  pt.utm_zone,
  pt.utm_easting,
  pt.utm_northing,
  v.life_stage_code,
  v.wscode_ltree as wscode,
  v.blue_line_key,
  s.stream_order
  --max_gradient_ds,
  --max_gradient100m_ds,
  --migration_dist_total,
  --migration_dist_lt05,
  --migration_dist_05_10,
  --migration_dist_10_15,
  --migration_dist_15_20,
  --migration_dist_20_25,
  --migration_dist_25_30,
  --migration_dist_gt30
from bcfishobs.fiss_fish_obsrvtn_events_vw v
inner join whse_fish.fiss_fish_obsrvtn_pnt_sp pt
on v.fish_observation_point_id = pt.fish_observation_point_id
inner join whse_basemapping.fwa_stream_networks_sp s on v.linear_feature_id = s.linear_feature_id
where v.species_code in ('CH','CM','CO','PK','SK','ST')
limit 100