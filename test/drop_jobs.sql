BEGIN
    FOR job IN (SELECT job_name FROM user_scheduler_jobs WHERE job_name LIKE 'DBX_STATS_%') LOOP
        BEGIN
            DBMS_SCHEDULER.drop_job(job_name => job.job_name, force => TRUE);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Error dropping job ' || job.job_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

