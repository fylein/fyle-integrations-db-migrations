DROP FUNCTION if exists ws_search;

CREATE OR REPLACE FUNCTION ws_search(_name text)
RETURNS TABLE(org_id integer, org_id character varying, org_name character varying)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  select id as org_id, fyle_org_id as org_id, name as org_name
  from orgs where name ilike '%' || _name || '%';
END;
$function$;
