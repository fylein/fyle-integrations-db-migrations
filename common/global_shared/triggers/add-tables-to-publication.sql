CREATE OR REPLACE FUNCTION public.add_tables_to_publication()
RETURNS event_trigger AS $$
DECLARE
    obj record;
    schema_name text;
    table_name text;
BEGIN
    FOR obj IN 
        SELECT * FROM pg_event_trigger_ddl_commands()
        WHERE command_tag = 'CREATE TABLE'
    LOOP
        RAISE NOTICE 'Processing new table: %', obj.object_identity;
        --- The format of the object_identity is schema.table
        schema_name := split_part(obj.object_identity, '.', 1);
        table_name := split_part(obj.object_identity, '.', 2);

        -- Skip if not in public schema
        IF schema_name <> 'public' THEN
            CONTINUE;
        END IF;

        -- Skip excluded system tables
        IF table_name IN (
            'django_admin_log', 
            'django_content_type', 
            'django_migrations',
            'django_q_ormq', 
            'django_q_schedule', 
            'django_q_task', 
            'django_session',
            'expense_attributes_deletion_cache'
        ) THEN
            RAISE NOTICE 'Skipping excluded table: %.%', schema_name, table_name;
            CONTINUE;
        END IF;

        RAISE NOTICE 'Processing new table: %.%', schema_name, table_name;

        -- Set REPLICA IDENTITY FULL
        EXECUTE format('ALTER TABLE %I.%I REPLICA IDENTITY FULL', schema_name, table_name);

        -- Add to publication (ignore duplicates)
        BEGIN
            EXECUTE format('ALTER PUBLICATION events ADD TABLE %I.%I', schema_name, table_name);
        EXCEPTION WHEN duplicate_object THEN
            RAISE NOTICE 'Table %.% already in publication.', schema_name, table_name;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
