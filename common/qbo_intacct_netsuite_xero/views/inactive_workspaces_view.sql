DROP VIEW IF EXISTS inactive_workspaces_view;

CREATE OR REPLACE VIEW inactive_workspaces_view AS
SELECT 
    COUNT(*), 
    current_database() AS database
FROM 
    workspaces
WHERE
    source_synced_at < NOW() - INTERVAL '2 months'
    AND destination_synced_at < NOW() - INTERVAL '2 months'
    AND last_synced_at < NOW() - INTERVAL '2 months'
    AND ccc_last_synced_at < NOW() - INTERVAL '2 months'
    AND id IN (SELECT id FROM prod_workspaces_view);
