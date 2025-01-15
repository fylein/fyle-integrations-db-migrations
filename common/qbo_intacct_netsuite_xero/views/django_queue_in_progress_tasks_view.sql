DROP VIEW IF EXISTS django_queue_in_progress_tasks_view;

---- Ground rules:
    -- Check historic data if there are alerts
    -- Alerts should be set for 1 count
CREATE OR REPLACE VIEW django_queue_in_progress_tasks_view AS
SELECT
    'IN_PROGRESS, ENQUEUED' AS status,
    COALESCE(COUNT(*), 0) AS count
FROM
    task_logs
WHERE
    workspace_id IN (SELECT id FROM prod_workspaces_view)
    AND status in ('IN_PROGRESS', 'ENQUEUED')
    AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '30 mins';
