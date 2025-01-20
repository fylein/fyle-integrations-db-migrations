DROP VIEW IF EXISTS _django_queue_fatal_tasks_view;

CREATE OR REPLACE VIEW _django_queue_fatal_tasks_view AS
SELECT
    'FATAL' AS status,
    COALESCE(COUNT(*), 0) AS count
FROM
    task_logs
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status = 'FATAL';
