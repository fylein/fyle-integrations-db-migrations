DROP VIEW IF EXISTS create_queue_fatal_in_progress_response_received_tasks_view;

CREATE OR REPLACE VIEW create_queue_fatal_in_progress_response_received_tasks_view AS
WITH create_request_queue_fatal_in_progress_response_received_tasks AS (
    SELECT COUNT(*) AS create_queue_fatal_in_progress_response_received_tasks_count
    FROM qbd_create_request_queue
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('FATAL', 'IN_PROGRESS', 'RESPONSE_RECEIVED')
        AND updated_at BETWEEN NOW() - INTERVAL '24 hours' AND NOW() - INTERVAL '45 mins'
)
SELECT * FROM create_request_queue_fatal_in_progress_response_received_tasks;
