drop view if exists prod_active_workspaces_view;

create or replace view prod_active_workspaces_view as

select 
    w.*,
    array_agg(u.email) as user_emails
from workspaces w
join workspaces_user wu on wu.workspace_id = w.id
join users u on u.id = wu.user_id
where u.email not ilike '%fyle%'
and w.id in (
    select distinct workspace_id from task_logs where status = 'COMPLETE' and type <> 'FETCHING_EXPENSES' and updated_at > now() - interval '3 months'
)
group by 1
;
