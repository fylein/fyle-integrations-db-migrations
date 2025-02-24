CREATE OR REPLACE FUNCTION add_tables_to_publication()
RETURNS event_trigger AS $$
BEGIN
    IF TG_EVENT = 'ddl_command_end' THEN
        -- Check if the created object is a table in public schema
        IF object_type = 'table' AND schema_name = 'public' THEN
            -- Exclude Django system tables
            IF NEW.table_name NOT IN (
                'django_admin_log',
                'django_content_type',
                'django_migrations',
                'django_q_ormq',
                'django_q_schedule',
                'django_q_task',
                'django_session'
            ) THEN
                EXECUTE format(
                    'ALTER PUBLICATION events ADD TABLE %I.%I',
                    schema_name,
                    NEW.table_name
                );
                
                EXECUTE format(
                    'ALTER TABLE %I.%I REPLICA IDENTITY FULL',
                    schema_name,
                    NEW.table_name
                );
            END IF;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER publication_table_trigger
ON ddl_command_end
WHEN TAG IN ('CREATE TABLE')
EXECUTE FUNCTION manage_publication_tables();
