DROP VIEW IF EXISTS _account_export_stuck_view;

CREATE OR REPLACE VIEW _account_export_stuck_view AS
SELECT
    workspace_id,
    COUNT(*) AS count
FROM
    accounting_exports
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status in ('IN_PROGRESS', 'EXPORT_QUEUED')
GROUP BY workspace_id;
