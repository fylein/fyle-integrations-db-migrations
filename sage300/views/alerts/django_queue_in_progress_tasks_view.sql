DROP VIEW IF EXISTS django_queue_in_progress_tasks_view;

CREATE OR REPLACE VIEW django_queue_in_progress_tasks_view AS
SELECT
    'IN_PROGRESS' AS status,
    COALESCE(COUNT(*), 0) AS count
FROM
    accounting_exports
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status = 'IN_PROGRESS'
    AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '30 mins';
