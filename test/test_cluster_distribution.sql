set SERVEROUTPUT on;
declare 
p_cluster varchar2(32) := 'true';
v_cluster boolean;
v_all_jobs NUMBER := 0;
v_job_name VARCHAR2(32);
v_instance_count NUMBER;
v_node_id NUMBER;
v_current_parallel_jobs NUMBER := 0;
CURSOR schema_cursor IS
            SELECT username
            FROM dba_users
            WHERE oracle_maintained = 'N'
              AND ('__REGEXP__^HR' = '__ALL__' OR
                   ('__REGEXP__^HR' LIKE '__REGEXP__%' AND REGEXP_LIKE(LOWER(username), '^hr')) OR
                   LOWER(username) = LOWER('__REGEXP__^HR'));
begin
    v_cluster := (lower(p_cluster) = lower('TRUE'));
     
    IF v_cluster THEN
        dbms_output.put_line('cluster true');
    END IF;
    
    IF v_cluster THEN
            SELECT COUNT(*)
            INTO v_instance_count
            FROM gv$instance;
    END IF;
    dbms_output.put_line('v_instance_count: '||v_instance_count);
    
    -- Initialize the count of all jobs
    FOR schema_rec IN schema_cursor LOOP
        v_all_jobs := v_all_jobs + 1;
    END LOOP;
    
    dbms_output.put_line('v_all_jobs: '||v_all_jobs);
     FOR schema_rec IN schema_cursor LOOP
        SELECT COUNT(*)
                INTO v_current_parallel_jobs
                FROM gv$session
                WHERE program = 'dbx_stats_client'
            ;
        -- Job name can be only 32 characters long
        v_job_name := SUBSTR(LOWER('dbx_stats_' || schema_rec.username ),1,32);
        
         IF v_cluster THEN
                -- Assign instance number for job
                v_node_id := MOD(v_all_jobs, v_instance_count) + 1;
         END IF;
        
        dbms_output.put_line('v_job_name: '||v_job_name||', node: '||v_node_id);
        v_all_jobs := v_all_jobs - 1;
    END LOOP;
    
end;
/
