DROP VIEW IF EXISTS account_export_stuck_view;

CREATE OR REPLACE VIEW account_export_stuck_view AS
SELECT
    workspace_id as workspace_id,
    COUNT(*) AS count
FROM
    accounting_exports
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status in ('IN_PROGRESS', 'EXPORT_QUEUED')
    AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '30 mins'
    AND type !~* 'fetching'
GROUP BY workspace_id;
