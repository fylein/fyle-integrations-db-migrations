DROP VIEW IF EXISTS inactive_workspaces_view;

CREATE OR REPLACE VIEW inactive_workspaces_view AS
SELECT 
    COUNT(DISTINCT w.id) AS count,
    current_database() AS database
FROM 
    workspaces w
JOIN 
    last_export_details led 
    ON w.id = led.workspace_id
JOIN 
    django_q_schedule dqs 
    ON w.id::text = dqs.args
WHERE 
    w.source_synced_at < (NOW() - INTERVAL '2 months') AND 
    w.destination_synced_at < (NOW() - INTERVAL '2 months') AND 
    w.last_synced_at < (NOW() - INTERVAL '2 months') AND 
    w.ccc_last_synced_at < (NOW() - INTERVAL '2 months') AND 
    led.last_exported_at < (NOW() - INTERVAL '2 months') AND 
    w.id IN (
        SELECT 
            id
        FROM 
            prod_workspaces_view
    );
