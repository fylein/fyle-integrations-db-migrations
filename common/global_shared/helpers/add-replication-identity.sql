DO $$
    DECLARE
        tbl RECORD;
    BEGIN
        FOR tbl IN 
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_type = 'BASE TABLE' AND table_schema = 'public'
        LOOP
            EXECUTE format('ALTER TABLE %I.%I REPLICA IDENTITY FULL', tbl.table_schema, tbl.table_name);
        END LOOP;
END $$;
