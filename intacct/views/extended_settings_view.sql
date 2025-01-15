drop view if exists extended_settings_view;
CREATE OR REPLACE VIEW extended_settings_view AS
 SELECT 
    row_to_json(w) AS workspaces,
    row_to_json(c) AS configurations,
    row_to_json(gm) AS general_mappings,
    row_to_json(ws) AS workspace_schedules,
    row_to_json(egs) AS expense_group_settings,
    row_to_json(led) AS last_export_details,
    w.fyle_org_id as fyle_org_id
FROM 
    workspaces w
LEFT JOIN 
    configurations c ON w.id = c.workspace_id
LEFT JOIN 
    general_mappings gm ON gm.workspace_id = w.id
LEFT JOIN 
    workspace_schedules ws ON ws.workspace_id = w.id
LEFT JOIN
    expense_group_settings egs ON egs.workspace_id = w.id
LEFT JOIN
    last_export_details led ON led.workspace_id = w.id
;
