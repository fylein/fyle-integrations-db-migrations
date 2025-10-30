DROP FUNCTION if exists delete_workspace;

CREATE OR REPLACE FUNCTION delete_workspace(IN _workspace_id integer) RETURNS void AS $$
DECLARE
  rcount integer;
  _org_id varchar(255);
  _fyle_org_id text;
  expense_ids text;
BEGIN
  RAISE NOTICE 'Deleting data from workspace % ', _workspace_id;

  _fyle_org_id := (select org_id from workspaces where id = _workspace_id);

  expense_ids := (
    select string_agg(format('%L', e.expense_id), ', ') 
    from expenses e
    where e.workspace_id = _workspace_id
  );

  DELETE
  FROM update_logs ul
  WHERE ul.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % update_logs', rcount;

  DELETE
  FROM export_logs_expenses ele
  WHERE ele.exportlog_id IN (
      SELECT el.id FROM export_logs el WHERE el.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_logs_expenses', rcount;

  DELETE
  FROM qbd_create_request_queue_export_logs qcrqel
  WHERE qcrqel.qbdcreaterequestqueue_id IN (
      SELECT qcrq.id FROM qbd_create_request_queue qcrq WHERE qcrq.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_create_request_queue_export_logs', rcount;

  DELETE
  FROM export_logs el
  WHERE el.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_logs', rcount;

  DELETE
  FROM failed_events fe
  WHERE fe.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % failed_events', rcount;

  DELETE
  FROM errors er
  where er.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % errors', rcount;

  DELETE 
  FROM import_logs il
  WHERE il.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % import_logs', rcount;

  DELETE
  FROM qbd_create_request_queue qcrq
  WHERE qcrq.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_create_request_queue', rcount;

  DELETE
  FROM qbd_add_request_queue qarq
  WHERE qarq.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_add_request_queue', rcount;

  DELETE
  FROM qbd_receive_request_queue qrrq
  WHERE qrrq.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_receive_request_queue', rcount;

  DELETE
  FROM bill_line_items bli
  WHERE bli.bill_id IN (
      SELECT b.id FROM bills b WHERE b.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % bill_line_items', rcount;

  DELETE
  FROM bills b
  WHERE b.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % bills', rcount;

  DELETE
  FROM credit_card_purchase_line_items ccpli
  WHERE ccpli.credit_card_purchase_id IN (
      SELECT ccp.id FROM credit_card_purchases ccp WHERE ccp.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % credit_card_purchase_line_items', rcount;

  DELETE
  FROM credit_card_purchases ccp
  WHERE ccp.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % credit_card_purchases', rcount;

  DELETE
  FROM journal_entry_line_items jeli
  WHERE jeli.journal_entry_id IN (
      SELECT je.id FROM journal_entries je WHERE je.workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % journal_entry_line_items', rcount;

  DELETE
  FROM journal_entries je
  WHERE je.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % journal_entries', rcount;

  DELETE
  FROM expenses e
  WHERE e.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expenses', rcount;

  DELETE
  FROM employee_mappings em
  WHERE em.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % employee_mappings', rcount;

  DELETE
  FROM category_mappings cm
  WHERE cm.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % category_mappings', rcount;

  DELETE
  FROM mappings m
  WHERE m.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % mappings', rcount;

  DELETE
  FROM mapping_settings ms
  WHERE ms.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % mapping_settings', rcount;

  DELETE
  FROM advanced_settings ads
  WHERE ads.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % advanced_settings', rcount;

  DELETE
  FROM export_settings es
  WHERE es.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_settings', rcount;

  DELETE
  FROM import_settings is_
  WHERE is_.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % import_settings', rcount;

  DELETE
  FROM connector_settings cs
  WHERE cs.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % connector_settings', rcount;

  DELETE
  FROM export_summary es
  WHERE es.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % export_summary', rcount;

  DELETE
  FROM fyle_credentials fc
  WHERE fc.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % fyle_credentials', rcount;

  DELETE
  FROM qbd_preferences qp
  WHERE qp.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_preferences', rcount;

  DELETE
  FROM qbd_sync_timestamps qst
  WHERE qst.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % qbd_sync_timestamps', rcount;

  DELETE
  from expense_attributes_deletion_cache ead
  WHERE ead.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_attributes_deletion_cache', rcount;

  DELETE
  FROM expense_attributes ea
  WHERE ea.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_attributes', rcount;

  DELETE
  FROM expense_filters ef
  WHERE ef.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % expense_filters', rcount;

  DELETE
  FROM destination_attributes da
  WHERE da.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % destination_attributes', rcount;

  DELETE
  FROM feature_configs fc
  WHERE fc.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % feature_configs', rcount;

  DELETE
  FROM fyle_sync_timestamps fst
  WHERE fst.workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % fyle_sync_timestamps', rcount;

  DELETE
  FROM django_q_schedule dqs
  WHERE dqs.args = _workspace_id::varchar(255);
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % django_q_schedule', rcount;

  DELETE
  FROM auth_tokens aut
  WHERE aut.user_id IN (
      SELECT u.id FROM users u WHERE u.id IN (
          SELECT wu.user_id FROM workspaces_user wu WHERE workspace_id = _workspace_id
      )
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % auth_tokens', rcount;

  DELETE
  FROM workspaces_user wu
  WHERE workspace_id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % workspaces_user', rcount;

  DELETE
  FROM users u
  WHERE u.id IN (
      SELECT wu.user_id FROM workspaces_user wu WHERE workspace_id = _workspace_id
  );
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % users', rcount;

  _org_id := (SELECT org_id FROM workspaces WHERE id = _workspace_id);

  DELETE
  FROM workspaces w
  WHERE w.id = _workspace_id;
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % workspaces', rcount;

  RAISE NOTICE E'\n\n\n\n\n\n\n\n\nSwitch to integration_settings db and run the below query to delete the integration';
  RAISE NOTICE E'\\c integration_settings; \n\n begin; select delete_integration(''%'');\n\n\n\n\n\n\n\n\n\n\n', _org_id;

  RAISE NOTICE E'\n\n\n\n\n\n\n\n\nSwitch to prod db and run the below query to update the subscription';
  RAISE NOTICE E'begin; update platform_schema.admin_subscriptions set is_enabled = false where org_id = ''%'';\n\n\n\n\n\n\n\n\n\n\n', _org_id;

  RAISE NOTICE E'\n\n\nProd DB Queries to delete accounting export summaries:';
  RAISE NOTICE E'rollback; begin; update platform_schema.expenses_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (%); update platform_schema.reports_wot set accounting_export_summary = \'{}\' where org_id = \'%\' and id in (select report->>\'id\' from platform_schema.expenses_rov where org_id = \'%\' and id in (%));', _fyle_org_id, expense_ids, _fyle_org_id, _fyle_org_id, expense_ids;

RETURN;
END
$$ LANGUAGE plpgsql;
