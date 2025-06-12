DROP VIEW IF EXISTS inactive_workspaces_view;

CREATE OR REPLACE VIEW inactive_workspaces_view AS
SELECT 
    COUNT(*), 
    current_database() AS database
FROM 
    workspaces w
JOIN 
    export_summary es 
    ON w.id = es.workspace_id
JOIN 
    django_q_schedule dqs 
    ON w.id::text = dqs.args
WHERE
    w.source_synced_at < NOW() - INTERVAL '2 months'
    AND w.reimbursable_last_synced_at < NOW() - INTERVAL '2 months'
    AND w.credit_card_last_synced_at < NOW() - INTERVAL '2 months'
    AND es.last_exported_at < NOW() - INTERVAL '2 months'
    AND w.id IN (SELECT id FROM prod_workspaces_view);
