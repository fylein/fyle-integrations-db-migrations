DROP VIEW IF EXISTS _create_queue_fatal_in_progress_response_received_tasks_view;

CREATE OR REPLACE VIEW _create_queue_fatal_in_progress_response_received_tasks_view AS
WITH create_request_queue_fatal_in_progress_response_received_tasks AS (
    SELECT status as status,
    COUNT(*) AS count
    FROM qbd_create_request_queue
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('FATAL', 'IN_PROGRESS', 'RESPONSE_RECEIVED')
        AND updated_at < NOW() - INTERVAL '45 mins'
    GROUP BY status
)
SELECT * FROM create_request_queue_fatal_in_progress_response_received_tasks;
