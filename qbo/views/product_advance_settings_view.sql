drop view if exists product_advanced_settings_view;
CREATE OR REPLACE VIEW product_advanced_settings_view AS
SELECT 
    w.id AS workspace_id,
    w.name AS workspace_name,
    w.fyle_org_id AS workspace_org_id,
    -- Workspace General Settings
    wgs.sync_fyle_to_qbo_payments,
    wgs.sync_qbo_to_fyle_payments,
    wgs.auto_create_destination_entity,
    wgs.auto_create_merchants_as_vendors,
    wgs.je_single_credit_line,
    wgs.change_accounting_period,
    wgs.memo_structure,
    -- General Mappings
    gm.bill_payment_account_id,
    gm.bill_payment_account_name,
    -- Workspace Schedules
    ws.enabled AS schedule_enabled,
    ws.interval_hours AS schedule_interval_hours,
    ws.additional_email_options AS schedule_additional_email_options,
    ws.emails_selected AS schedule_emails_selected
FROM 
    workspaces w
JOIN 
    workspace_general_settings wgs ON w.id = wgs.workspace_id
JOIN 
    general_mappings gm ON w.id = gm.workspace_id
LEFT JOIN 
    workspace_schedules ws ON w.id = ws.workspace_id
;
