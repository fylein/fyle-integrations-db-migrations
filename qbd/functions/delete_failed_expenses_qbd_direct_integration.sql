DROP FUNCTION IF EXISTS delete_failed_expenses;

CREATE OR REPLACE FUNCTION delete_failed_expenses(
    IN _workspace_id INTEGER, 
    IN _delete_all BOOLEAN DEFAULT false, 
    _export_log_ids INTEGER[] DEFAULT '{}'
) RETURNS void AS $$

DECLARE
    rcount INTEGER;
    temp_expenses INTEGER[];
    local_export_log_ids INTEGER[];
    _fyle_org_id text;
    expense_ids text;
BEGIN
    RAISE NOTICE 'Deleting failed expenses from workspace % ', _workspace_id; 

    local_export_log_ids := _export_log_ids;

    -- If delete_all is true, select all export logs with ERROR status
    IF _delete_all THEN
        SELECT array_agg(id) INTO local_export_log_ids 
        FROM export_logs 
        WHERE status = 'ERROR' AND workspace_id = _workspace_id;
        
        UPDATE export_summary 
        SET failed_export_log_count = 0 
        WHERE workspace_id = _workspace_id;
        
        GET DIAGNOSTICS rcount = ROW_COUNT;
        RAISE NOTICE 'Updated % export_summary', rcount;
    END IF;

    -- Get the related expense ids from export_logs_expenses
    SELECT array_agg(expense_id) INTO temp_expenses 
    FROM export_logs_expenses 
    WHERE exportlog_id = ANY(local_export_log_ids);

    _fyle_org_id := (select org_id from workspaces where id = _workspace_id);

    expense_ids := (
        select string_agg(format('%L', expense_id), ', ') 
        from expenses
        where workspace_id = _workspace_id
        and id in (SELECT unnest(temp_expenses))
    );

    -- Delete from export_logs_expenses first to avoid foreign key constraint violations
    DELETE FROM export_logs_expenses 
    WHERE exportlog_id = ANY(local_export_log_ids);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % export_logs_expenses', rcount;

    -- Delete from errors table
    DELETE FROM errors 
    WHERE export_log_id = ANY(local_export_log_ids);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % errors', rcount;

    -- Delete from export_logs now that the foreign key constraint is no longer an issue
    DELETE FROM export_logs 
    WHERE id = ANY(local_export_log_ids) 
    AND workspace_id = _workspace_id 
    AND status = 'ERROR';
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % export_logs', rcount;

    -- Delete from expenses related to these logs
    DELETE FROM expenses 
    WHERE id = ANY(temp_expenses);
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % expenses', rcount;

	-- Delete from qbd_add_request_queue
	DELETE 
	FROM qbd_add_request_queue WHERE workspace_id = _workspace_id AND export_log_id in (SELECT unnest(local_export_log_ids));
	GET DIAGNOSTICS rcount = ROW_COUNT;
	RAISE NOTICE 'Deleted % qbd_add_request_queue', rcount;

    -- Update the export summary to reflect the change
    RAISE NOTICE 'IF FAILED EXPORT LOGS COUNT IS 0, THEN RUN THIS';
    RAISE NOTICE 'UPDATE export_summary set failed_export_log_count = 0 WHERE workspace_id = %;', _workspace_id;

    RAISE NOTICE E'\n\n\nProd DB Queries to delete accounting export summaries:';
    RAISE NOTICE E'rollback; begin; update platform_schema.expenses_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (%); update platform_schema.reports_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (select report->>\'id\' from platform_schema.expenses_rov where org_id = \'%\' and id in (%));', _fyle_org_id, expense_ids, _fyle_org_id, _fyle_org_id, expense_ids;

    RETURN;
END
$$ LANGUAGE plpgsql;
