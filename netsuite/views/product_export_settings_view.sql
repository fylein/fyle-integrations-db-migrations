CREATE VIEW product_export_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    c.reimbursable_expenses_object,
    c.corporate_credit_card_expenses_object,
    c.is_simplify_report_closure_enabled,
    c.name_in_journal_entry,
    c.employee_field_mapping,
    c.auto_map_employees,
    -- Expense Group Settings
    egs.reimbursable_expense_group_fields,
    case when reimbursable_expense_group_fields @> ARRAY['expense_id']::varchar[] OR reimbursable_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_reimbursable_expense_group_fields,
    egs.corporate_credit_card_expense_group_fields,
    case when corporate_credit_card_expense_group_fields @> ARRAY['expense_id']::varchar[] OR corporate_credit_card_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_corporate_credit_card_expense_group_fields,
    egs.reimbursable_export_date_type,
    egs.expense_state,
    egs.corporate_credit_card_expense_group_fields,
    egs.ccc_export_date_type,
    egs.ccc_expense_state,
    -- General Mappings
    gm.accounts_payable_name,
    gm.accounts_payable_id,
    gm.default_ccc_account_name,
    gm.default_ccc_account_id,
    gm.reimbursable_account_name,
    gm.reimbursable_account_id,
    gm.default_ccc_vendor_name,
    gm.default_ccc_vendor_id
FROM
    workspaces w
JOIN
    configurations c ON w.id = c.workspace_id
JOIN
    expense_group_settings egs ON w.id = egs.workspace_id
JOIN
    general_mappings gm ON w.id = gm.workspace_id;
