DROP VIEW IF EXISTS product_export_settings_view;
CREATE VIEW product_export_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    c.reimbursable_expenses_object,
    c.corporate_credit_card_expenses_object,
    c.is_simplify_report_closure_enabled,
    c.employee_field_mapping,
    c.auto_map_employees,
    c.use_merchant_in_journal_line,
    -- Expense Group Settings
    egs.reimbursable_expense_group_fields,
    case when reimbursable_expense_group_fields @> ARRAY['expense_id']::varchar[] OR reimbursable_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_reimbursable_expense_group_fields,
    egs.corporate_credit_card_expense_group_fields,
    case when corporate_credit_card_expense_group_fields @> ARRAY['expense_id']::varchar[] OR corporate_credit_card_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_corporate_credit_card_expense_group_fields,
    egs.reimbursable_export_date_type,
    egs.expense_state,
    egs.ccc_export_date_type,
    egs.ccc_expense_state,
    egs.split_expense_grouping,
    -- General Mappings
    gm.default_gl_account_name,
    gm.default_gl_account_id,
    gm.default_credit_card_name,
    gm.default_credit_card_id,
    gm.default_charge_card_name,
    gm.default_charge_card_id,
    gm.default_reimbursable_expense_payment_type_name,
    gm.default_reimbursable_expense_payment_type_id,
    gm.default_ccc_expense_payment_type_name,
    gm.default_ccc_expense_payment_type_id,
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
