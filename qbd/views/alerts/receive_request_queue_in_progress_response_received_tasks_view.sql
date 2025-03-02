DROP VIEW IF EXISTS receive_request_queue_in_progress_response_received_tasks_view;

CREATE OR REPLACE VIEW receive_request_queue_in_progress_response_received_tasks_view AS 
WITH receive_request_queue_in_progress_response_received_tasks AS (
    SELECT COUNT(*) AS receive_request_queue_in_progress_response_received_tasks_count
    FROM qbd_receive_request_queue
    WHERE
        workspace_id IN (SELECT id FROM prod_workspaces_view)
        AND status IN ('IN_PROGRESS', 'RESPONSE_RECEIVED')
        AND updated_at < (NOW() - INTERVAL '45 minutes')
)
SELECT * FROM receive_request_queue_in_progress_response_received_tasks;
