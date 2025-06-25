drop view if exists huge_export_volume_view;

create or replace view huge_export_volume_view as
select 
    workspace_id,
    COUNT(*) as count
from task_logs
where 
    status in ('ENQUEUED', 'IN_PROGRESS')
    and type not ilike '%fetching%'
    and workspace_id in (select id from prod_workspaces_view)
    and updated_at >= (now() - interval '1 day')
group by workspace_id
having COUNT(*) > 500;
