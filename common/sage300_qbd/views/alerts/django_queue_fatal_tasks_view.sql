DROP VIEW IF EXISTS django_queue_fatal_tasks_view;

CREATE OR REPLACE VIEW django_queue_fatal_tasks_view AS
SELECT
    'FATAL' AS status,
    COALESCE(COUNT(*), 0) AS count
FROM
    accounting_exports
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status = 'FATAL'
    AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '30 mins';
