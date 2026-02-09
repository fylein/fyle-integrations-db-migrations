DROP VIEW IF EXISTS attachment_failed_count_view;

CREATE VIEW attachment_failed_count_view AS 
select 
  current_database() as database, 
  count(*) 
from 
  task_logs 
where 
  workspace_id in (
    select 
      id 
    from 
      prod_workspaces_view
  ) 
  and updated_at > now() - interval '3 days' 
  and is_attachment_upload_failed = 'true';
