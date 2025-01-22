drop view if exists extended_expenses_view;

create or replace view extended_expenses_view as

select 
    e.*,

    eg.id as expense_group_id,
    eg.employee_name as expense_group_employee_name,
    eg.export_url as expense_group_export_url,
    eg.description as expense_group_description,
    eg.created_at as expense_group_created_at,
    eg.updated_at as expense_group_updated_at,
    eg.workspace_id as expense_group_workspace_id,
    eg.fund_source as expense_group_fund_source,
    eg.exported_at as expense_group_exported_at,
    eg.response_logs as expense_group_response_logs

from expenses e

join expense_groups_expenses ege on ege.expense_id = e.id
join expense_groups eg on eg.id = ege.expensegroup_id
;
