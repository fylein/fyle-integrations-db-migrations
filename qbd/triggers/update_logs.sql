CREATE TABLE IF NOT EXISTS update_logs (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    old_data JSONB,
    new_data JSONB,
    difference JSONB,
    operation_type TEXT,
    workspace_id INT,
    created_at TIMESTAMP DEFAULT NOW()
);


--- create triggers
DROP TRIGGER IF EXISTS monitor_creates ON workspaces_user;
CREATE TRIGGER monitor_creates
AFTER INSERT ON workspaces_user
FOR EACH ROW
EXECUTE FUNCTION log_create_event();


---- update triggers
DROP TRIGGER IF EXISTS monitor_updates ON import_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON import_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON export_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON export_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON advanced_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON advanced_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON connector_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON connector_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON mapping_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON mapping_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON expense_filters;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON expense_filters
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON mappings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON mappings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON employee_mappings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON employee_mappings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON destination_attributes;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON destination_attributes
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON import_logs;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON import_logs
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON qbd_add_request_queue;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON qbd_add_request_queue
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON qbd_create_request_queue;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON qbd_create_request_queue
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON qbd_receive_request_queue;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON qbd_receive_request_queue
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON workspaces;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON workspaces
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON workspaces_user;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON workspaces_user
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON export_summary;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON export_summary
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON qbd_sync_timestamps;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON qbd_sync_timestamps
FOR EACH ROW
EXECUTE FUNCTION log_update_event();


--- delete triggers
DROP TRIGGER IF EXISTS monitor_deletes ON mapping_settings;
CREATE TRIGGER monitor_deletes
AFTER DELETE ON mapping_settings
FOR EACH ROW
EXECUTE FUNCTION log_delete_event();

DROP TRIGGER IF EXISTS monitor_deletes ON expense_filters;
CREATE TRIGGER monitor_deletes
AFTER DELETE ON expense_filters
FOR EACH ROW
EXECUTE FUNCTION log_delete_event();
