CREATE TABLE dbx_job_record_log (
    job_id NUMBER GENERATED BY DEFAULT AS IDENTITY,
    g_session_id VARCHAR2(32),
    schema_name VARCHAR2(128),
    job_name VARCHAR2(128),
    job_status VARCHAR2(30),
    start_time TIMESTAMP,
    duration INTERVAL DAY TO SECOND,
    instance_number NUMBER,
    dbms_scheduler_status VARCHAR2(30), 
    dbms_scheduler_error NUMBER,
    dbms_scheduler_info VARCHAR2(4000),
    session_id VARCHAR2(30),
    PRIMARY KEY (job_id)
);

