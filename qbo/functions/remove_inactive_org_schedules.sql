DROP FUNCTION IF EXISTS remove_inactive_org_schedules;

CREATE OR REPLACE FUNCTION remove_inactive_org_schedules() RETURNS void AS $$

DECLARE
  inactive_orgs integer[];
  rcount integer;

BEGIN
  RAISE NOTICE 'Removing Schedules for Inactive Orgs ...';

  SELECT
      array_agg(distinct w.id) INTO inactive_orgs
  FROM
      workspaces w
      JOIN last_export_details lsd ON w.id = lsd.workspace_id
      JOIN django_q_schedule dqs ON w.id::text = dqs.args
  WHERE
      w.source_synced_at < NOW() - INTERVAL '2 months'
      AND w.destination_synced_at < NOW() - INTERVAL '2 months'
      AND w.last_synced_at < NOW() - INTERVAL '2 months'
      AND w.ccc_last_synced_at < NOW() - INTERVAL '2 months'
      AND lsd.last_exported_at < NOW() - INTERVAL '2 months'
      AND w.id IN (SELECT id FROM prod_workspaces_view);

  RAISE NOTICE 'Inactive Orgs: %', inactive_orgs;

  DELETE
  FROM django_q_schedule 
  WHERE args::integer IN (SELECT unnest(inactive_orgs));
  GET DIAGNOSTICS rcount = ROW_COUNT;
  RAISE NOTICE 'Deleted % schedules', rcount;

RETURN;
END
$$ LANGUAGE plpgsql;
