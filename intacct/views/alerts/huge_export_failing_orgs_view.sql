drop view if exists huge_export_failing_orgs_view;

create or replace view huge_export_failing_orgs_view as
select 
    workspace_id,
    failed_expense_groups_count as count
from last_export_details 
where 
    failed_expense_groups_count > 50
    and workspace_id in (select id from prod_workspaces_view);