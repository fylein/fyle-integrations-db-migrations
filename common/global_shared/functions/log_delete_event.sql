CREATE OR REPLACE FUNCTION log_delete_event()
    RETURNS TRIGGER AS
$$
DECLARE difference jsonb;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO update_logs(table_name, old_data, operation_type, workspace_id)
        VALUES (TG_TABLE_NAME, to_jsonb(OLD), 'DELETE', OLD.workspace_id);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
