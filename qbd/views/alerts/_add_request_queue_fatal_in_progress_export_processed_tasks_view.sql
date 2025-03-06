DROP VIEW IF EXISTS _add_queue_fatal_in_progress_export_processed_tasks_view;

CREATE OR REPLACE VIEW _add_queue_fatal_in_progress_export_processed_tasks_view AS
WITH add_request_queue_fatal_in_progress_export_processed_tasks AS (
    SELECT COUNT(*) AS count
    FROM qbd_add_request_queue
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('FATAL', 'IN_PROGRESS', 'EXPORT_PROCESSED')
        AND updated_at < NOW() - INTERVAL '45 mins'
)
SELECT * FROM add_request_queue_fatal_in_progress_export_processed_tasks;