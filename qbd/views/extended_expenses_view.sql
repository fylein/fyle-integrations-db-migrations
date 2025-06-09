drop view if exists extended_expenses_view;

create or replace view extended_expenses_view as

select 
    e.*,

    eg.id as export_log_id,
    eg.description as export_log_description,
    eg.created_at as export_log_created_at,
    eg.updated_at as export_log_updated_at,
    eg.workspace_id as export_log_workspace_id,
    eg.fund_source as export_log_fund_source,
    eg.exported_at as export_log_exported_at

from expenses e

join export_logs_expenses ege on ege.expense_id = e.id
join export_logs eg on eg.id = ege.exportlog_id;
