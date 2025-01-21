DROP VIEW IF EXISTS product_advanced_settings_view;
CREATE OR REPLACE VIEW product_advanced_settings_view AS
SELECT
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    c.change_accounting_period,
    c.sync_fyle_to_netsuite_payments,
    c.sync_netsuite_to_fyle_payments,
    c.auto_create_destination_entity,
    c.memo_structure,
    -- General Mappings
    gm.vendor_payment_account_name,
    gm.vendor_payment_account_id,
    gm.location_name AS netsuite_location_name,
    gm.location_id AS netsuite_location_id,
    gm.location_level AS netsuite_location_level,
    gm.department_name AS netsuite_department_name,
    gm.department_id AS netsuite_department_id,
    gm.department_level AS netsuite_department_level,
    gm.class_name AS netsuite_class_name,
    gm.class_id AS netsuite_class_id,
    gm.class_level AS netsuite_class_level,
    gm.use_employee_location,
    gm.use_employee_department,
    gm.use_employee_class,
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
