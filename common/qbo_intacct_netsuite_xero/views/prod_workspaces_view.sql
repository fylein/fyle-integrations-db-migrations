drop view if exists prod_workspaces_view;

create or replace view prod_workspaces_view as

select 
    w.*,
    array_agg(u.email) as user_emails
from workspaces w
join workspaces_user wu on wu.workspace_id = w.id
join users u on u.id = wu.user_id
where u.email not ilike '%fyle%'
group by 1
;
