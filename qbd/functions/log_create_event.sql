DROP FUNCTION IF EXISTS log_create_event;

CREATE OR REPLACE FUNCTION log_create_event()
    RETURNS TRIGGER AS
$$
DECLARE difference jsonb;
BEGIN
    IF (TG_OP = 'CREATE') THEN
        INSERT INTO update_logs(table_name, old_data, operation_type, workspace_id)
        VALUES (TG_TABLE_NAME, to_jsonb(OLD), 'CREATE', OLD.workspace_id);
    ELSIF TG_TABLE_NAME = 'workspaces' THEN
        INSERT INTO update_logs(table_name, old_data, operation_type, workspace_id)
        VALUES (TG_TABLE_NAME, to_jsonb(OLD), 'CREATE', OLD.id);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
