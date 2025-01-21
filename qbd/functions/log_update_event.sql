CREATE OR REPLACE FUNCTION log_update_event()
    RETURNS TRIGGER AS
$$
DECLARE
    difference jsonb;
    key_count int;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        difference := json_diff(to_jsonb(OLD), to_jsonb(NEW));

        -- Count the number of keys in the difference JSONB object
        SELECT COUNT(*)
        INTO key_count
        FROM jsonb_each_text(difference);

        -- If difference has only the key updated_at, then ignore and don't insert into update_logs
        IF NOT (key_count = 1 AND difference ? 'updated_at') THEN
            IF TG_TABLE_NAME = 'qbd_receive_request_queue' THEN
                difference := difference - 'response';
                INSERT INTO update_logs(table_name, old_data, new_data, difference, workspace_id, operation_type)
                VALUES (TG_TABLE_NAME, to_jsonb(OLD) - 'response', to_jsonb(NEW) - 'response', difference, OLD.workspace_id, 'UPDATE');
            ELSIF TG_TABLE_NAME = 'workspaces' THEN
                INSERT INTO update_logs(table_name, old_data, new_data, difference, workspace_id, operation_type)
                VALUES (TG_TABLE_NAME, to_jsonb(OLD) - 'updated_at', to_jsonb(NEW) - 'updated_at', difference, OLD.id, 'UPDATE');
            ELSE
                INSERT INTO update_logs(table_name, old_data, new_data, difference, workspace_id, operation_type)
                VALUES (TG_TABLE_NAME, to_jsonb(OLD), to_jsonb(NEW), difference, OLD.workspace_id, 'UPDATE');
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
