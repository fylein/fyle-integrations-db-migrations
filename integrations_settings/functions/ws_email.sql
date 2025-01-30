DROP FUNCTION if exists ws_email;

CREATE OR REPLACE FUNCTION ws_email(_org_id integer)
RETURNS TABLE(workspace_id integer, workspace_name character varying, email character varying)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
   RETURN QUERY
   SELECT w.id AS org_id, w.name AS workspace_name, u.email AS email 
   FROM orgs w
   LEFT JOIN orgs_user wu ON wu.org_id = w.id
   LEFT JOIN users u ON wu.user_id = u.id
   WHERE w.id = _org_id;
END;
$function$;
