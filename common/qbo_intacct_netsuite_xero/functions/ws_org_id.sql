DROP FUNCTION if exists ws_org_id;

CREATE OR REPLACE FUNCTION ws_org_id(_org_id text)
RETURNS TABLE(workspace_id integer, workspace_org_id character varying, workspace_name character varying)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  select id as workspace_id, fyle_org_id as workspace_org_id, name as workspace_name
  from workspaces where fyle_org_id = _org_id;
END;
$function$;
