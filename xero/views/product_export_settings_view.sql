DROP VIEW IF EXISTS product_export_settings_view;
CREATE VIEW product_export_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    wgs.reimbursable_expenses_object,
    wgs.corporate_credit_card_expenses_object,
    -- Expense Group Settings
    egs.reimbursable_expense_group_fields,
    case when reimbursable_expense_group_fields @> ARRAY['expense_id']::varchar[] OR reimbursable_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_reimbursable_expense_group_fields,
    egs.corporate_credit_card_expense_group_fields,
    case when corporate_credit_card_expense_group_fields @> ARRAY['expense_id']::varchar[] OR corporate_credit_card_expense_group_fields @> ARRAY['expense_number']::varchar[] THEN 'Expense' ELSE 'Report' END AS readable_corporate_credit_card_expense_group_fields,
    egs.reimbursable_export_date_type,
    egs.reimbursable_expense_state,
    egs.ccc_export_date_type,
    egs.ccc_expense_state,
    -- General Mappings
    gm.bank_account_name,
    gm.bank_account_id
FROM
    workspaces w
JOIN
    workspace_general_settings wgs ON w.id = wgs.workspace_id
JOIN
    expense_group_settings egs ON w.id = egs.workspace_id
JOIN
    general_mappings gm ON w.id = gm.workspace_id;
