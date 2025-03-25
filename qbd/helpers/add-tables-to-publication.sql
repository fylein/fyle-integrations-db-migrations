DO $$
    DECLARE
        tables_list text;
    BEGIN
        SELECT string_agg(quote_ident(tablename), ', ')
        INTO tables_list
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename NOT IN (
            'django_admin_log', 
            'django_content_type', 
            'django_migrations',
            'django_q_ormq', 
            'django_q_schedule', 
            'django_q_task', 
            'django_session',
            'update_logs',
            'qbd_receive_request_queue',
            'expense_attributes_deletion_cache'
        );

        EXECUTE 'CREATE PUBLICATION events FOR TABLE ' || tables_list;
END
$$;
