drop view if exists extended_expenses_view;

create or replace view extended_expenses_view as

select 
    e.id,
    e.employee_email,
    e.employee_name,
    e.category,
    e.sub_category,
    e.project,
    e.org_id,
    e.expense_id,
    e.expense_number,
    e.claim_number,
    e.amount,
    e.currency,
    e.foreign_amount,
    e.foreign_currency,
    e.tax_amount,
    e.tax_group_id,
    e.settlement_id,
    e.reimbursable,
    e.billable,
    -- e.exported,
    e.state,
    e.vendor,
    e.cost_center,
    e.purpose,
    e.report_id,
    e.report_title,
    e.corporate_card_id,
    e.bank_transaction_id,
    e.file_ids,
    e.spent_at,
    e.approved_at,
    e.posted_at,
    e.expense_created_at,
    e.expense_updated_at,
    e.created_at,
    e.updated_at,
    e.fund_source,
    e.verified_at,
    e.custom_properties,
    e.previous_export_state,
    e.accounting_export_summary,
    e.paid_on_sage_intacct,
    e.paid_on_fyle,
    -- e.payment_number,
    e.is_skipped,
    e.workspace_id,

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
