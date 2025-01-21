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


DROP TRIGGER IF EXISTS monitor_updates ON workspace_general_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON workspace_general_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON general_mappings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON general_mappings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON expense_group_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON expense_group_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON workspace_schedules;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON workspace_schedules
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON xero_credentials;

DROP TRIGGER IF EXISTS monitor_deletes ON xero_credentials;
CREATE TRIGGER monitor_deletes
AFTER DELETE ON xero_credentials
FOR EACH ROW
EXECUTE FUNCTION log_delete_event();

DROP TRIGGER IF EXISTS monitor_updates ON mapping_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON mapping_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON fyle_credentials;

DROP TRIGGER IF EXISTS monitor_updates ON expenses;
