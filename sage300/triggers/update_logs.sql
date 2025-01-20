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

DROP TRIGGER IF EXISTS monitor_updates ON export_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON export_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON mapping_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON mapping_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();

DROP TRIGGER IF EXISTS monitor_updates ON advanced_settings;
CREATE TRIGGER monitor_updates
AFTER UPDATE ON advanced_settings
FOR EACH ROW
EXECUTE FUNCTION log_update_event();
