DROP FUNCTION IF EXISTS delete_export_logs;

CREATE OR REPLACE FUNCTION delete_exported_export_logs(
    IN _workspace_id integer, 
    IN _delete_all boolean DEFAULT false, 
    IN _status text DEFAULT NULL,
    _export_log_ids integer[] DEFAULT '{}'
) RETURNS void AS $$

DECLARE
    rcount integer;
    local_export_log_ids integer[];
BEGIN
    RAISE NOTICE 'Deleting export logs from workspace %', _workspace_id; 

    local_export_log_ids := _export_log_ids;

    IF _delete_all THEN
        -- Delete all export logs for the workspace
        SELECT array_agg(id) INTO local_export_log_ids 
        FROM export_logs 
        WHERE workspace_id = _workspace_id;
        RAISE NOTICE 'Selected all export_logs for deletion from workspace %', _workspace_id;
    ELSIF array_length(local_export_log_ids, 1) IS NULL OR array_length(local_export_log_ids, 1) = 0 THEN
        -- If no specific export_log_ids provided, filter by status
        IF _status IS NOT NULL THEN
            IF _status = 'NULL' THEN
                SELECT array_agg(id) INTO local_export_log_ids 
                FROM export_logs 
                WHERE workspace_id = _workspace_id AND status IS NULL;
            ELSE
                SELECT array_agg(id) INTO local_export_log_ids 
                FROM export_logs 
                WHERE workspace_id = _workspace_id AND status = _status;
            END IF;
            RAISE NOTICE 'Selected export_logs with status % from workspace %', _status, _workspace_id;
        ELSE
            RAISE NOTICE 'No export_logs selected for deletion - no criteria provided';
            RETURN;
        END IF;
    ELSE
        RAISE NOTICE 'Using provided export_log_ids: %', local_export_log_ids;
    END IF;

    -- If no export_logs found, exit
    IF array_length(local_export_log_ids, 1) IS NULL OR array_length(local_export_log_ids, 1) = 0 THEN
        RAISE NOTICE 'No export_logs found matching criteria';
        RETURN;
    END IF;

    -- Delete Bill Line Items first (child records)
    DELETE FROM bill_line_items bli
    WHERE bli.bill_id IN (
        SELECT b.id FROM bills b 
        WHERE b.export_log_id IN (SELECT unnest(local_export_log_ids))
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bill_line_items', rcount;

    -- Delete Bills
    DELETE FROM bills b
    WHERE b.export_log_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % bills', rcount;

    -- Delete Credit Card Purchase Line Items first (child records)
    DELETE FROM credit_card_purchase_line_items ccpli
    WHERE ccpli.credit_card_purchase_id IN (
        SELECT ccp.id FROM credit_card_purchases ccp 
        WHERE ccp.export_log_id IN (SELECT unnest(local_export_log_ids))
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % credit_card_purchase_line_items', rcount;

    -- Delete Credit Card Purchases
    DELETE FROM credit_card_purchases ccp
    WHERE ccp.export_log_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % credit_card_purchases', rcount;

    -- Delete Journal Entry Line Items first (child records)
    DELETE FROM journal_entry_line_items jeli
    WHERE jeli.journal_entry_id IN (
        SELECT je.id FROM journal_entries je 
        WHERE je.export_log_id IN (SELECT unnest(local_export_log_ids))
    );
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entry_line_items', rcount;

    -- Delete Journal Entries
    DELETE FROM journal_entries je
    WHERE je.export_log_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % journal_entries', rcount;

    -- Delete QBD Add Request Queue entries
    DELETE FROM qbd_add_request_queue qarq
    WHERE qarq.export_log_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % qbd_add_request_queue', rcount;

    -- Delete many-to-many relationships between qbd_create_request_queue and export_logs
    DELETE FROM qbd_create_request_queue_export_logs qcrqel
    WHERE qcrqel.exportlog_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % qbd_create_request_queue_export_logs', rcount;

    -- Delete many-to-many relationships between export_logs and expenses
    DELETE FROM export_logs_expenses ele
    WHERE ele.exportlog_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % export_logs_expenses', rcount;

    -- Delete errors related to export logs
    DELETE FROM errors e
    WHERE e.export_log_id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % errors', rcount;

    -- Delete export_logs
    DELETE FROM export_logs el
    WHERE el.id IN (SELECT unnest(local_export_log_ids));
    GET DIAGNOSTICS rcount = ROW_COUNT;
    RAISE NOTICE 'Deleted % export_logs', rcount;

    -- Update export_summary if not deleting all
    IF NOT _delete_all THEN
        UPDATE export_summary 
        SET total_export_log_count = COALESCE(total_export_log_count, 0) - rcount,
            updated_at = NOW()
        WHERE workspace_id = _workspace_id;
        GET DIAGNOSTICS rcount = ROW_COUNT;
        RAISE NOTICE 'Updated % export_summary', rcount;
    END IF;

    RAISE NOTICE 'Completed deleting export logs from workspace %', _workspace_id;

    RETURN;
END
$$ LANGUAGE plpgsql;
