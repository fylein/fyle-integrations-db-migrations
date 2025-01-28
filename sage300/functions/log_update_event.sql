DROP FUNCTION if exists log_update_event;

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

        -- If difference has only the key updated_at, then insert into update_logs
        IF NOT (key_count = 1 AND difference ? 'updated_at') THEN
            INSERT INTO update_logs(table_name, old_data, new_data, difference, workspace_id)
            VALUES (TG_TABLE_NAME, to_jsonb(OLD), to_jsonb(NEW), difference, OLD.workspace_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;
