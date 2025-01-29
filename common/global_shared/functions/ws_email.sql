DROP FUNCTION if exists ws_email;

CREATE OR REPLACE FUNCTION ws_email(_workspace_id integer)
RETURNS TABLE(workspace_id integer, workspace_name character varying, email character varying)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  select w.id as workspace_id, w.name as workspace_name, u.email as email from workspaces w 
    left join workspaces_user wu on wu.workspace_id = w.id
    left join users u on wu.user_id = u.id
    where w.id = _workspace_id;
END;
$function$;
