DROP VIEW IF EXISTS product_advanced_settings_view;
CREATE OR REPLACE VIEW product_advanced_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    c.change_accounting_period,
    c.sync_fyle_to_sage_intacct_payments,
    c.sync_sage_intacct_to_fyle_payments,
    c.auto_create_destination_entity,
    c.memo_structure,
    c.auto_create_merchants_as_vendors,
    -- General Mappings
    gm.payment_account_name,
    gm.payment_account_id,
    gm.default_location_name AS default_location_name,
    gm.default_location_id AS default_location_id,
    gm.default_project_name AS default_project_name,
    gm.default_project_id AS default_project_id,
    gm.default_item_name AS default_item_name,
    gm.default_item_id AS default_item_id,
    gm.use_intacct_employee_departments,
    gm.use_intacct_employee_locations,
    -- Workspace Schedules
    ws.enabled AS schedule_enabled,
    ws.interval_hours AS schedule_interval_hours,
    ws.additional_email_options AS schedule_additional_email_options,
    ws.emails_selected AS schedule_emails_selected
FROM
    workspaces w
JOIN
    configurations c ON w.id = c.workspace_id
JOIN
    general_mappings gm ON w.id = gm.workspace_id
LEFT JOIN
    workspace_schedules ws ON w.id = ws.workspace_id;
