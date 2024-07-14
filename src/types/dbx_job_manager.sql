CREATE OR REPLACE TYPE dbx_job_manager AS OBJECT (
    job_name VARCHAR2(128),
    schema_name VARCHAR2(128),
    instance_number NUMBER,
    
    -- Member procedures
    MEMBER PROCEDURE insert_log(p_status VARCHAR2),
    MEMBER PROCEDURE update_log(p_status VARCHAR2, p_duration INTERVAL DAY TO SECOND DEFAULT NULL),
    MEMBER PROCEDURE clean_up_logs
);
/

CREATE OR REPLACE TYPE BODY dbx_job_manager AS

    -- Procedure to insert initial job record into the log table
    MEMBER PROCEDURE insert_log(p_status VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO dbx_job_record_log (
            schema_name, job_name, job_status, start_time, instance_number
        ) VALUES (
            SELF.schema_name, SELF.job_name, p_status, SYSTIMESTAMP, SELF.instance_number
        );
        COMMIT;
    END insert_log;

    -- Procedure to update job record in the log table
    MEMBER PROCEDURE update_log(p_status VARCHAR2, p_duration INTERVAL DAY TO SECOND DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF p_status = 'RUNNING' THEN
            UPDATE dbx_job_record_log
            SET job_status = p_status
            WHERE job_name = SELF.job_name;
        ELSIF p_status = 'COMPLETED' THEN
            UPDATE dbx_job_record_log
            SET job_status = p_status, duration = p_duration
            WHERE job_name = SELF.job_name;
        END IF;
        COMMIT;
    END update_log;

    -- Procedure to clean up job logs based on retention setting
    MEMBER PROCEDURE clean_up_logs IS
        v_retention NUMBER;
    BEGIN
        -- Get retention period from settings
        SELECT TO_NUMBER(setting_value) INTO v_retention
        FROM dbx_stats_settings
        WHERE LOWER(setting_name) = 'job_log_retention';

        -- Delete old job logs
        DELETE FROM dbx_job_record_log
        WHERE start_time < SYSTIMESTAMP - INTERVAL '1' DAY * v_retention;
        COMMIT;
    END clean_up_logs;

END;
/

