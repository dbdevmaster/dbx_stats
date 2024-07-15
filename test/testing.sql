SET SERVEROUTPUT ON
DECLARE
    CURSOR result_cursor IS
        SELECT schema_name, job_name, job_status, duration, instance_number
        FROM TABLE(dbx_stats.gather_schema_stats('ADMIN', 4, 'TRUE'));
    v_result_row result_cursor%ROWTYPE;
BEGIN
    OPEN result_cursor;
    LOOP
        FETCH result_cursor INTO v_result_row;
        EXIT WHEN result_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Schema: ' || v_result_row.schema_name || 
                             ', Job Name: ' || v_result_row.job_name || 
                             ', Status: ' || v_result_row.job_status || 
                             ', Duration: ' || TO_CHAR(v_result_row.duration, 'HH24:MI:SS') || 
                             ', Instance: ' || v_result_row.instance_number);
    END LOOP;
    CLOSE result_cursor;
END;
/

select * from DBX_STATS_SETTINGS;
-- Get job status
SELECT * FROM TABLE(dbx_stats.get_job_status);
select 'exec dbms_scheduler.drop_job('''||job_name||''');' from user_scheduler_jobs where job_name like 'DBX%';
select * from dba_scheduler_job_run_details where lower(job_name) = lower('dbx_stats_gather_schema_stats_admin_20240713_190411');
              exec DBMS_SCHEDULER.PURGE_LOG(job_name => 'dbx_stats_gather_schema_stats_admin_20240713_190411');



select * from v$session where client_info is not null;

SELECT log_id,
       job_name,
       status,
       log_date,
       error#,
       additional_info
FROM user_scheduler_job_run_details
WHERE lower(job_name) = lower('dbx_stats_gather_schema_stats_admin_20240713_182656')
ORDER BY log_date DESC;

--truncate table dbx_job_record_log;

 SELECT log_id, status, error#, additional_info
                FROM dba_scheduler_job_run_details
                WHERE LOWER(job_name) = lower('dbx_stats_gather_schema_stats_ADMIN_20240713_163808')
                ORDER BY log_date DESC
                FETCH FIRST ROW ONLY;



SELECT log_id, status, error#, additional_info
                    FROM dba_scheduler_job_run_details
                    where lower(job_name) = lower('dbx_stats_gather_schema_stats_ADMIN_20240713_180241');
                    

declare
        v_debugging VARCHAR2(50);
        v_manager dbx_stats_manager := dbx_stats_manager('debugging');
    BEGIN
        v_debugging := v_manager.get_setting();
        dbms_output.put_line(v_debugging);
END;
/



SELECT log_id, status, error#, additional_info
            FROM dba_scheduler_job_run_details
            WHERE lower(job_name) = ('dbx_stats_gather_schema_stats_admin_20240713_202504')
            ORDER BY log_date DESC
            FETCH FIRST ROW ONLY;


select * FROM dba_scheduler_jobs 
            WHERE lower(job_name) = ('dbx_stats_gather_schema_stats_admin_20240713_202504')
            FETCH FIRST ROW ONLY;
