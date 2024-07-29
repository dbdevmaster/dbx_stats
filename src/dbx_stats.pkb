CREATE OR REPLACE PACKAGE BODY dbx_stats AS

    -- Function to check if trace is enabled
    FUNCTION is_trace_enabled RETURN BOOLEAN IS
        v_trace VARCHAR2(50);
        v_manager dbx_stats_manager := dbx_stats_manager('trace');
    BEGIN
        v_trace := v_manager.get_setting();
        RETURN (LOWER(v_trace) = 'enabled');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END is_trace_enabled;

    -- Function to check if debugging is enabled
    FUNCTION is_debugging_enabled RETURN BOOLEAN IS
        v_debugging VARCHAR2(50);
        v_manager dbx_stats_manager := dbx_stats_manager('debugging');
    BEGIN
        v_debugging := v_manager.get_setting();
        RETURN (LOWER(v_debugging) = 'enabled');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END is_debugging_enabled;

    -- Procedure to print debugging messages if debugging is enabled
    PROCEDURE debugging(p_message VARCHAR2) IS
    BEGIN
        IF is_debugging_enabled() THEN
            DBMS_OUTPUT.PUT_LINE(p_message);
        END IF;
    END debugging;

    -- Autonomous procedure to create a watcher job
    PROCEDURE create_watcher_job(g_session_id VARCHAR2, v_max_parallel_jobs number, v_instance_count NUMBER) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_owner VARCHAR2(128);
    BEGIN
      -- Get the current user
      SELECT USER INTO v_owner FROM dual;

      -- Create the watcher job
      DBMS_SCHEDULER.CREATE_JOB(
          job_name        => 'D__WATCHER__D',
          job_type        => 'PLSQL_BLOCK',
          job_action      => 'BEGIN
                              DBMS_SESSION.SET_IDENTIFIER(''' || g_session_id || ''');
                              DBMS_APPLICATION_INFO.SET_CLIENT_INFO(''dbx_stats_client'');
                              DBMS_APPLICATION_INFO.SET_MODULE(''dbx_stats_module'', ''gather_schema_stats'');
                              DBMS_APPLICATION_INFO.SET_ACTION(''WATCHER'');
                              ' || v_owner || '.dbx_stats.watch_jobs(''' || g_session_id || ''', ' || v_max_parallel_jobs || ', ' || v_instance_count || '); 
                              END;',
          start_date      => SYSTIMESTAMP + INTERVAL '120' SECOND,
          enabled         => TRUE,
          end_date        => NULL,
          auto_drop       => TRUE,
          comments        => 'Watcher job to monitor and manage gather schema stats jobs'
      );
  
      DBMS_SCHEDULER.RUN_JOB('D__WATCHER__D', FALSE);
  
  EXCEPTION
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error in create_watcher_job: ' || SQLERRM);
          IF is_trace_enabled() THEN
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
          END IF;
          ROLLBACK;
  END create_watcher_job;

    -- Autonomous procedure to create and run gather job
  PROCEDURE create_gather_job(
    p_job_name VARCHAR2, 
    p_schema_name VARCHAR2, 
    p_instance_number NUMBER, 
    p_max_job_runtime NUMBER,
    p_g_session_id VARCHAR2,
    p_degree NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_offset NUMBER := 0;
    v_limit NUMBER;
    v_limit_string VARCHAR2(100);
    v_limit_setting dbx_stats_manager := dbx_stats_manager('FETCH_LIMIT'); -- Fetch the limit setting from dbx_stats_manager
    v_debugging_enabled BOOLEAN;
  BEGIN
    v_debugging_enabled := is_debugging_enabled();
    v_limit_string := v_limit_setting.get_setting; -- Get the limit setting value
    v_limit := TO_NUMBER(v_limit_string); -- Convert the VARCHAR2 value to NUMBER

    IF v_debugging_enabled THEN
        debugging('Starting create_gather_job procedure...');
    END IF;

    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => LOWER(p_job_name),
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'DECLARE
                                v_offset NUMBER := 0;
                            BEGIN 
                                DBMS_SESSION.SET_IDENTIFIER(''' || p_g_session_id || ''');
                                DBMS_APPLICATION_INFO.SET_CLIENT_INFO(''dbx_stats_client'');
                                DBMS_APPLICATION_INFO.SET_MODULE(''dbx_stats_module'', ''gather_schema_stats'');
                                DBMS_APPLICATION_INFO.SET_ACTION(''Schema: '' || ''' || p_schema_name || ''' || '''');
                                
                                -- Gather schema stats
                                DBMS_STATS.GATHER_SCHEMA_STATS(ownname => ''' || p_schema_name || ''', degree=> '''|| p_degree || ''');
                                
                                -- Gather stale index stats
                                LOOP
                                    FOR rec IN (SELECT index_name 
                                                FROM (SELECT index_name, ROWNUM rnum 
                                                      FROM dba_ind_statistics 
                                                      WHERE owner = ''' || p_schema_name || ''' 
                                                        AND stale_stats = ''YES''
                                                      AND ROWNUM <= ' || v_limit || ') 
                                                WHERE rnum > v_offset) LOOP
                                        DBMS_APPLICATION_INFO.SET_MODULE(''dbx_stats_module'', ''gather_index_stats'');
                                        DBMS_APPLICATION_INFO.SET_ACTION(''SchemaIndex: ''|| ''' || p_schema_name || '.'' || rec.index_name );
                                        DBMS_STATS.GATHER_INDEX_STATS(
                                            ownname => ''' || p_schema_name || ''',
                                            indname => rec.index_name,
                                            degree => ''' || p_degree || '''
                                        );
                                    END LOOP;
                                    
                                    v_offset := v_offset + ' || v_limit || ';
                                    EXIT WHEN SQL%NOTFOUND;
                                END LOOP;

                                v_offset := 0;
                                
                                -- Gather empty index stats
                                LOOP
                                    FOR rec IN (SELECT index_name 
                                                FROM (SELECT index_name, ROWNUM rnum 
                                                      FROM dba_ind_statistics 
                                                      WHERE owner = ''' || p_schema_name || ''' 
                                                        AND stale_stats IS NULL
                                                      AND ROWNUM <= ' || v_limit || ') 
                                                WHERE rnum > v_offset) LOOP
                                        DBMS_APPLICATION_INFO.SET_MODULE(''dbx_stats_module'', ''gather_index_stats'');
                                        DBMS_APPLICATION_INFO.SET_ACTION(''SchemaIndex: ''|| ''' || p_schema_name || '.'' || rec.index_name );
                                        DBMS_STATS.GATHER_INDEX_STATS(
                                            ownname => ''' || p_schema_name || ''',
                                            indname => rec.index_name,
                                            degree => ''' || p_degree || '''
                                        );
                                    END LOOP;
                                    
                                    v_offset := v_offset + ' || v_limit || ';
                                    EXIT WHEN SQL%NOTFOUND;
                                END LOOP;

                                -- Optional: Sleep to simulate extended processing time
                                DBMS_SESSION.SLEEP(5);
                            END;',
        start_date      => SYSTIMESTAMP,
        end_date        => NULL,
        enabled         => FALSE,  -- Change to FALSE
        comments        => 'Gather stats for schema ' || p_schema_name,
        auto_drop       => FALSE
    );

    IF p_instance_number IS NOT NULL THEN
        DBMS_SCHEDULER.SET_ATTRIBUTE(LOWER(p_job_name), 'INSTANCE_ID', p_instance_number);
        debugging('set attribute instance_id for job_name: '||p_job_name||' to: '||p_instance_number);
    END IF;
    DBMS_SESSION.SLEEP(1);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
        debugging('Error in create_gather_job: ' || SQLERRM);
        IF is_trace_enabled() THEN
            debugging(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            debugging(DBMS_UTILITY.FORMAT_ERROR_STACK);
        END IF;
        ROLLBACK;
  END create_gather_job;
  
    -- Autonomous procedure to insert initial job record into the log table
    PROCEDURE insert_job_record(v_g_session_id VARCHAR2, p_schema_name VARCHAR2, p_job_name VARCHAR2, p_instance_number NUMBER, p_session_id VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO dbx_job_record_log (
            g_session_id, schema_name, job_name, job_status, start_time, instance_number, session_id
        ) VALUES (
            v_g_session_id, p_schema_name, LOWER(p_job_name), 'QUEUED', SYSTIMESTAMP, p_instance_number, p_session_id
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in insert_job_record: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
            ROLLBACK;
    END insert_job_record;

    -- Autonomous procedure to update job record in the log table
    PROCEDURE update_job_record(v_g_session_id VARCHAR2, p_job_name VARCHAR2, p_status VARCHAR2, p_duration INTERVAL DAY TO SECOND DEFAULT NULL, p_dbms_scheduler_status VARCHAR2 DEFAULT NULL, p_dbms_scheduler_error NUMBER DEFAULT NULL, p_dbms_scheduler_info VARCHAR2 DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF p_status = 'RUNNING' THEN
            UPDATE dbx_job_record_log
            SET job_status = p_status
            WHERE job_name = LOWER(p_job_name) AND g_session_id = v_g_session_id;
        ELSIF p_status = 'COMPLETED' THEN
            UPDATE dbx_job_record_log
            SET job_status = p_status, duration = p_duration, dbms_scheduler_status = p_dbms_scheduler_status, dbms_scheduler_error = p_dbms_scheduler_error, dbms_scheduler_info = p_dbms_scheduler_info
            WHERE job_name = LOWER(p_job_name) AND g_session_id = v_g_session_id;
        ELSIF p_status = 'STOPPED' THEN
            UPDATE dbx_job_record_log
            SET job_status = p_status, duration = p_duration, dbms_scheduler_status = p_dbms_scheduler_status, dbms_scheduler_error = p_dbms_scheduler_error, dbms_scheduler_info = p_dbms_scheduler_info
            WHERE job_name = LOWER(p_job_name) AND g_session_id = v_g_session_id;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in update_job_record: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
            ROLLBACK;
    END update_job_record;


    -- Autonomous procedure to get stale objects
    PROCEDURE gather_stale_objects(schema_name VARCHAR2, objlist OUT dbms_stats.objecttab) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- Set module and action info for gather_stale_objects
        DBMS_APPLICATION_INFO.SET_MODULE('dbx_stats_module', 'gather_stale_objects');
        DBMS_APPLICATION_INFO.SET_ACTION('Schema: ' || schema_name);

        debugging('gather_stale_objects: Gathering stale objects for schema: ' || schema_name);

        DBMS_STATS.GATHER_SCHEMA_STATS(ownname => schema_name, options => 'LIST STALE', objlist => objlist);

        -- Clear module and action info
        DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
        DBMS_APPLICATION_INFO.SET_ACTION(NULL);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in gather_stale_objects: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END gather_stale_objects;

    -- Autonomous procedure to get empty objects
    PROCEDURE gather_empty_objects(schema_name VARCHAR2, objlist OUT dbms_stats.objecttab) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- Set module and action info for gather_empty_objects
        DBMS_APPLICATION_INFO.SET_MODULE('dbx_stats_module', 'gather_empty_objects');
        DBMS_APPLICATION_INFO.SET_ACTION('Schema: ' || schema_name);

        debugging('gather_empty_objects: Gathering empty objects for schema: ' || schema_name);

        DBMS_STATS.GATHER_SCHEMA_STATS(ownname => schema_name, options => 'LIST EMPTY', objlist => objlist);

        -- Clear module and action info
        DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
        DBMS_APPLICATION_INFO.SET_ACTION(NULL);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in gather_empty_objects: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END gather_empty_objects;

    -- Autonomous procedure to drop a job
    PROCEDURE drop_job(p_job_name VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(p_job_name, DEFER=>FALSE, FORCE=>TRUE);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in drop_job: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
            ROLLBACK;
    END drop_job;

    -- Autonomous procedure to purge scheduler logs
    PROCEDURE purge_log(p_job_name VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DBMS_SCHEDULER.PURGE_LOG(job_name => p_job_name);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in purge_log: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
            ROLLBACK;
    END purge_log;

    FUNCTION get_prefs_schema_tbls(v_schema_to_check VARCHAR2)
        RETURN dbx_pref_table PIPELINED
    IS
        v_regexp VARCHAR2(128);
        v_quoted_object_name VARCHAR2(258); -- Adjusted to accommodate quotes and object name length
        CURSOR schema_cursor IS
            SELECT username
            FROM dba_users
            WHERE oracle_maintained = 'N'
              AND (v_schema_to_check = '__ALL__' OR
                   (v_schema_to_check LIKE '__REGEXP__%' AND REGEXP_LIKE(LOWER(username), v_regexp)) OR
                   LOWER(username) = LOWER(v_schema_to_check));
        pref_value VARCHAR2(4000);

        CURSOR pref_cursor IS
            SELECT pname
            FROM dbx_stats_prefs
            WHERE enabled = 'Y';

    BEGIN
        -- Set application info
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO('dbx_stats_client');
        DBMS_APPLICATION_INFO.SET_MODULE('dbx_stats_module', 'get_prefs_schema_tbls');
        DBMS_APPLICATION_INFO.SET_ACTION('Parameter: ' || v_schema_to_check);

        debugging('get_prefs_schema_tbls: Parameter: ' || v_schema_to_check);

        -- Extract the regular expression if provided
        IF v_schema_to_check LIKE '__REGEXP__%' THEN
            v_regexp := LOWER(SUBSTR(v_schema_to_check, 11));
        END IF;

        FOR schema_rec IN schema_cursor LOOP
            -- Checking the preferences for partitioned tables
            FOR object_rec IN (SELECT DISTINCT table_name AS object_name
                              FROM dba_tab_partitions
                              WHERE LOWER(table_owner) = LOWER(schema_rec.username)) LOOP
                v_quoted_object_name := '"' || object_rec.object_name || '"';
                FOR pref_rec IN pref_cursor LOOP
                    BEGIN
                        -- Set action info for preference retrieval
                        DBMS_APPLICATION_INFO.SET_ACTION('Getting Pref: ' || pref_rec.pname || ' for ' || schema_rec.username || '.' || object_rec.object_name);

                        debugging('get_prefs_schema_tbls: Getting Pref: ' || pref_rec.pname || ' for ' || schema_rec.username || '.' || object_rec.object_name);

                        BEGIN
                            pref_value := DBMS_STATS.GET_PREFS(pref_rec.pname, schema_rec.username, v_quoted_object_name);
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pref_value := 'No data found';
                        END;

                        PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'Y', pref_rec.pname, pref_value));

                        -- Clear action info after preference retrieval
                        DBMS_APPLICATION_INFO.SET_ACTION(NULL);
                    EXCEPTION
                        WHEN OTHERS THEN
                            IF SQLCODE = -20000 THEN
                                PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'Y', pref_rec.pname, 'Skipped due to ORA-20000'));
                            ELSE
                                PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'Y', pref_rec.pname, 'Error: ' || SQLERRM));
                            END IF;
                            DBMS_OUTPUT.PUT_LINE('Error in get_prefs_schema_tbls (inside loop): ' || SQLERRM);
                            IF is_trace_enabled() THEN
                              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
                            END IF;
                    END;
                END LOOP;
            END LOOP;

            -- Checking the preferences for non-partitioned tables
            FOR object_rec IN (SELECT DISTINCT table_name AS object_name
                              FROM dba_tables
                              WHERE LOWER(owner) = LOWER(schema_rec.username)
                                AND partitioned = 'NO') LOOP
                v_quoted_object_name := '"' || object_rec.object_name || '"';
                FOR pref_rec IN pref_cursor LOOP
                    BEGIN
                        -- Set action info for preference retrieval
                        DBMS_APPLICATION_INFO.SET_ACTION('Getting Pref: ' || pref_rec.pname || ' for ' || schema_rec.username || '.' || object_rec.object_name);

                        debugging('get_prefs_schema_tbls: Getting Pref: ' || pref_rec.pname || ' for ' || schema_rec.username || '.' || object_rec.object_name);

                        BEGIN
                            pref_value := DBMS_STATS.GET_PREFS(pref_rec.pname, schema_rec.username, v_quoted_object_name);
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                pref_value := 'No data found';
                        END;

                        PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'N', pref_rec.pname, pref_value));

                        -- Clear action info after preference retrieval
                        DBMS_APPLICATION_INFO.SET_ACTION(NULL);
                    EXCEPTION
                        WHEN OTHERS THEN
                            IF SQLCODE = -20000 THEN
                                PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'N', pref_rec.pname, 'Skipped due to ORA-20000'));
                            ELSE
                                PIPE ROW(dbx_pref_record(schema_rec.username, 'TABLE', object_rec.object_name, 'N', pref_rec.pname, 'Error: ' || SQLERRM));
                            END IF;
                            DBMS_OUTPUT.PUT_LINE('Error in get_prefs_schema_tbls (inside loop): ' || SQLERRM);
                            
                            IF is_trace_enabled() THEN
                              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
                              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
                            END IF;
                    END;
                END LOOP;
            END LOOP;
        END LOOP;

        -- Clear application info
        DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(NULL);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_prefs_schema_tbls: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END get_prefs_schema_tbls;

    FUNCTION get_stale_stats_schema(v_schema_to_check VARCHAR2)
        RETURN dbx_stale_stats_table PIPELINED
    IS
        v_regexp VARCHAR2(128);
        mystaleobjs dbms_stats.objecttab; -- Collection to hold stale objects
        myemptyobjs dbms_stats.objecttab; -- Collection to hold empty objects
        v_stale_stats VARCHAR2(4000);
        v_table_stats_status VARCHAR2(4000);
        v_index_stats_status VARCHAR2(4000);
        v_partitioned_status VARCHAR2(1);
        CURSOR schema_cursor IS
            SELECT username
            FROM dba_users
            WHERE oracle_maintained = 'N'
              AND (v_schema_to_check = '__ALL__' OR
                   (v_schema_to_check LIKE '__REGEXP__%' AND REGEXP_LIKE(LOWER(username), v_regexp)) OR
                   LOWER(username) = LOWER(v_schema_to_check));

    BEGIN
        -- Set application info
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO('dbx_stats_client');
        DBMS_APPLICATION_INFO.SET_MODULE('dbx_stats_module', 'get_stale_stats_schema');
        DBMS_APPLICATION_INFO.SET_ACTION('Parameter: ' || v_schema_to_check);

        debugging('get_stale_stats_schema: Parameter: ' || v_schema_to_check);

        -- Extract the regular expression if provided
        IF v_schema_to_check LIKE '__REGEXP__%' THEN
            v_regexp := LOWER(SUBSTR(v_schema_to_check, 11));
        END IF;

        FOR schema_rec IN schema_cursor LOOP
            -- Initialize the collections
            mystaleobjs := dbms_stats.objecttab();
            myemptyobjs := dbms_stats.objecttab();

            -- Set action for gathering stale objects
            DBMS_APPLICATION_INFO.SET_ACTION('Gathering Stale Objects for Schema: ' || schema_rec.username);
            gather_stale_objects(schema_rec.username, mystaleobjs);

            -- Set action for gathering empty objects
            DBMS_APPLICATION_INFO.SET_ACTION('Gathering Empty Objects for Schema: ' || schema_rec.username);
            gather_empty_objects(schema_rec.username, myemptyobjs);

            -- Process the collection of stale objects
            FOR i IN 1..mystaleobjs.COUNT LOOP
                -- Determine if the object is partitioned
                IF mystaleobjs(i).objtype = 'TABLE' THEN
                    BEGIN
                        SELECT CASE WHEN partitioned = 'YES' THEN 'Y' ELSE 'N' END
                        INTO v_partitioned_status
                        FROM dba_tables
                        WHERE owner = schema_rec.username
                          AND table_name = mystaleobjs(i).objname;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_partitioned_status := 'N'; -- Default to 'N' if not found
                    END;
                ELSIF mystaleobjs(i).objtype = 'INDEX' THEN
                    BEGIN
                        SELECT CASE WHEN partitioned = 'YES' THEN 'Y' ELSE 'N' END
                        INTO v_partitioned_status
                        FROM dba_indexes
                        WHERE owner = schema_rec.username
                          AND index_name = mystaleobjs(i).objname;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_partitioned_status := 'N'; -- Default to 'N' if not found
                    END;
                ELSE
                    v_partitioned_status := 'N'; -- Default to 'N' if type is not TABLE or INDEX
                END IF;

                PIPE ROW(dbx_stale_stats_record(
                    schema_rec.username,
                    mystaleobjs(i).objtype,
                    mystaleobjs(i).objname,
                    v_partitioned_status,
                    mystaleobjs(i).partname,
                    'DBMS_STATS-STALE'
                ));
            END LOOP;

            -- Process the collection of empty objects
            FOR i IN 1..myemptyobjs.COUNT LOOP
                -- Determine if the object is partitioned
                IF myemptyobjs(i).objtype = 'TABLE' THEN
                    BEGIN
                        SELECT CASE WHEN partitioned = 'YES' THEN 'Y' ELSE 'N' END
                        INTO v_partitioned_status
                        FROM dba_tables
                        WHERE owner = schema_rec.username
                          AND table_name = myemptyobjs(i).objname;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_partitioned_status := 'N'; -- Default to 'N' if not found
                    END;
                ELSIF myemptyobjs(i).objtype = 'INDEX' THEN
                    BEGIN
                        SELECT CASE WHEN partitioned = 'YES' THEN 'Y' ELSE 'N' END
                        INTO v_partitioned_status
                        FROM dba_indexes
                        WHERE owner = schema_rec.username
                          AND index_name = myemptyobjs(i).objname;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_partitioned_status := 'N'; -- Default to 'N' if not found
                    END;
                ELSE
                    v_partitioned_status := 'N'; -- Default to 'N' if type is not TABLE or INDEX
                END IF;

                PIPE ROW(dbx_stale_stats_record(
                    schema_rec.username,
                    myemptyobjs(i).objtype,
                    myemptyobjs(i).objname,
                    v_partitioned_status,
                    myemptyobjs(i).partname,
                    'DBMS_STATS-EMPTY'
                ));
            END LOOP;

            -- Check table statistics status
            FOR table_stat_rec IN (
                SELECT ts.table_name, ts.stale_stats, t.partitioned
                FROM dba_tab_statistics ts
                JOIN dba_tables t ON ts.owner = t.owner AND ts.table_name = t.table_name
                WHERE ts.owner = schema_rec.username
            ) LOOP
                IF table_stat_rec.stale_stats = 'YES' THEN
                    PIPE ROW(dbx_stale_stats_record(
                        schema_rec.username,
                        'TABLE',
                        table_stat_rec.table_name,
                        CASE WHEN table_stat_rec.partitioned = 'YES' THEN 'Y' ELSE 'N' END,
                        NULL,
                        'DBA_TAB_STATISTICS'
                    ));
                END IF;
            END LOOP;

            -- Check index statistics status
            FOR index_stat_rec IN (
                SELECT dis.index_name, dis.stale_stats, i.partitioned
                FROM dba_ind_statistics dis
                JOIN dba_indexes i ON dis.owner = i.owner AND dis.index_name = i.index_name
                WHERE dis.owner = schema_rec.username
            ) LOOP
                IF index_stat_rec.stale_stats = 'YES' THEN
                    PIPE ROW(dbx_stale_stats_record(
                        schema_rec.username,
                        'INDEX',
                        index_stat_rec.index_name,
                        CASE WHEN index_stat_rec.partitioned = 'YES' THEN 'Y' ELSE 'N' END,
                        NULL,
                        'DBA_IND_STATISTICS'
                    ));
                END IF;
            END LOOP;
        END LOOP;

        -- Clear application info
        DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(NULL);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_stale_stats_schema: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END get_stale_stats_schema;

    PROCEDURE set_prefs(
        p_schema_name  IN VARCHAR2,
        p_table_name   IN VARCHAR2 DEFAULT NULL,
        p_pname        IN VARCHAR2,
        p_value        IN VARCHAR2
    ) IS
        v_regexp VARCHAR2(128);
        v_partitioned_status VARCHAR2(1);
        v_pref_count NUMBER;
        v_quoted_object_name VARCHAR2(258);
        TYPE table_rec_type IS RECORD (
            table_name VARCHAR2(128),
            partitioned VARCHAR2(3)
        );
        TYPE table_list IS TABLE OF table_rec_type;
        v_table_list table_list;
        CURSOR schema_cursor IS
            SELECT username
            FROM dba_users
            WHERE oracle_maintained = 'N'
              AND (p_schema_name = '__ALL__' OR
                   (p_schema_name LIKE '__REGEXP__%' AND REGEXP_LIKE(LOWER(username), v_regexp)) OR
                   LOWER(username) = LOWER(p_schema_name));
        CURSOR table_cursor(schema_name VARCHAR2) IS
            SELECT table_name, partitioned
            FROM dba_tables
            WHERE owner = schema_name;
    BEGIN
        -- Check if p_pname exists in dbx_stats_prefs
        SELECT COUNT(*)
        INTO v_pref_count
        FROM dbx_stats_prefs
        WHERE pname = p_pname;

        IF v_pref_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Preference name ' || p_pname || ' does not exist in dbx_stats_prefs');
        END IF;

        -- Set application info
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO('dbx_stats_client');
        DBMS_APPLICATION_INFO.SET_MODULE('dbx_stats_module', 'set_prefs');
        DBMS_APPLICATION_INFO.SET_ACTION('Parameter: ' || p_schema_name || ', ' || NVL(p_table_name, 'Schema level'));

        debugging('set_prefs: Parameter: ' || p_schema_name || ', Table: ' || NVL(p_table_name, 'Schema level'));

        -- Extract the regular expression if provided
        IF p_schema_name LIKE '__REGEXP__%' THEN
            v_regexp := LOWER(SUBSTR(p_schema_name, 11));
        END IF;

        FOR schema_rec IN schema_cursor LOOP
            IF p_table_name IS NULL THEN
                OPEN table_cursor(schema_rec.username);
                FETCH table_cursor BULK COLLECT INTO v_table_list;
                CLOSE table_cursor;
                FOR i IN 1..v_table_list.COUNT LOOP
                    v_quoted_object_name := '"' || v_table_list(i).table_name || '"';
                    debugging('set_prefs: Parameter: ' || p_schema_name || ', Table: ' || v_table_list(i).table_name ||', Parameter: '|| p_pname ||', Value: '||p_value);
                    debugging('set_prefs: Parameter: ' || p_schema_name || ', Table: ' || v_table_list(i).table_name ||', Partitioned: '||v_table_list(i).partitioned);
                    IF v_table_list(i).partitioned = 'YES' THEN
                        CASE upper(p_pname)
                            WHEN 'INCREMENTAL' THEN
                                debugging('----------- '||p_pname||' -------------');
                                debugging('DBMS_STATS.SET_TABLE_PREFS(ownname=>'''||schema_rec.username||''', tabname=>'''||v_quoted_object_name||''', pname=>'''||p_pname||''', pvalue=>'''||p_value||''');');
                                DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>p_value);
                                debugging('----------- '||p_pname||' -------------');
                            WHEN 'GRANULARITY' THEN
                                DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>'default');
                            WHEN 'OPTIONS' THEN
                                DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>'gather');
                            ELSE    
                                DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>p_value);
                        END CASE;
                    ELSE    
                        CASE upper(p_pname)
                            WHEN 'INCREMENTAL' THEN
                                IF lower(p_value) = 'false'
                                THEN
                                    DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>p_value);
                                END IF;
                            ELSE    
                                DBMS_STATS.SET_TABLE_PREFS(ownname=>schema_rec.username, tabname=>v_quoted_object_name, pname=>p_pname, pvalue=>p_value);
                        END CASE;
                    END IF;
                END LOOP;
            ELSE
                -- Determine if the table is partitioned if pname is 'INCREMENTAL'
                v_quoted_object_name := '"' || p_table_name || '"';
                BEGIN
                    SELECT CASE WHEN partitioned = 'YES' THEN 'Y' ELSE 'N' END
                    INTO v_partitioned_status
                    FROM dba_tables
                    WHERE owner = schema_rec.username
                      AND table_name = p_table_name;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_partitioned_status := 'N'; -- Default to 'N' if not found
                END;

                IF v_partitioned_status = 'Y' THEN
                    -- Set preference at the table level for partitioned table
                    CASE upper(p_pname)
                            WHEN 'INCREMENTAL' THEN
                                DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, p_value);
                            WHEN 'GRANULARITY' THEN
                                DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, 'default');
                            WHEN 'OPTIONS' THEN
                                DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, 'gather');
                            ELSE    
                                DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, p_value);
                        END CASE;
                ELSE 
                    CASE upper(p_pname)
                        WHEN 'INCREMENTAL' THEN
                        IF lower(p_value) = 'flase'
                        THEN
                            DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, p_value);
                        END IF;
                        ELSE
                            DBMS_STATS.SET_TABLE_PREFS(schema_rec.username, v_quoted_object_name, p_pname, p_value);
                    END CASE;
                END IF;

            END IF;
        END LOOP;

        -- Clear application info
        DBMS_APPLICATION_INFO.SET_MODULE(NULL, NULL);
        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(NULL);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in set_prefs: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END set_prefs;

  FUNCTION gather_schema_stats(
    p_schema_name IN VARCHAR2,
    p_degree      IN INTEGER,
    p_cluster     IN VARCHAR2 DEFAULT 'FALSE'
  ) RETURN dbx_job_table PIPELINED IS
    v_max_job_runtime number;
    v_cluster BOOLEAN;
    v_regexp VARCHAR2(128);
    v_instance_number NUMBER;
    v_instance_count NUMBER;
    v_job_name VARCHAR2(32);
    v_current_parallel_jobs NUMBER := 0;
    v_max_parallel_jobs NUMBER := p_degree;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration INTERVAL DAY TO SECOND;
    v_job_status dbx_job_table := dbx_job_table(); -- Collection to hold job records
    v_all_jobs NUMBER := 0;
    v_running_jobs NUMBER := 0;
    v_node_id NUMBER;
    v_session_id VARCHAR2(30);
    g_session_id VARCHAR(32);

    CURSOR schema_cursor IS
        SELECT username
        FROM dba_users
        WHERE oracle_maintained = 'N'
          AND (p_schema_name = '__ALL__' OR
               (p_schema_name LIKE '__REGEXP__%' AND REGEXP_LIKE(LOWER(username), v_regexp)) OR
               LOWER(username) = LOWER(p_schema_name));

  BEGIN
    g_session_id := RAWTOHEX(SYS_GUID());

    v_start_time := SYSTIMESTAMP;

    v_max_job_runtime := TO_NUMBER(dbx_stats_manager('max_job_duration').get_setting) * 60 + 1; -- Add a few ticks to max job runtime

    -- Determine if clustering is enabled
    v_cluster := (lower(p_cluster) = lower('TRUE'));

    -- Extract the regular expression if provided
    IF p_schema_name LIKE '__REGEXP__%' THEN
        v_regexp := LOWER(SUBSTR(p_schema_name, 11));
        debugging('v_regexp: '||v_regexp);
    END IF;

    -- Determine instance number if cluster option is enabled
    IF v_cluster THEN
        SELECT instance_number
        INTO v_instance_number
        FROM v$instance;
    END IF;

    -- Determine the number of instances if cluster option is enabled
    IF v_cluster THEN
        SELECT COUNT(*)
        INTO v_instance_count
        FROM gv$instance;
    END IF;

    -- Initialize the count of all jobs
    FOR schema_rec IN schema_cursor LOOP
        v_all_jobs := v_all_jobs + 1;
    END LOOP;

    -- Create a watcher job
    create_watcher_job(g_session_id, v_max_parallel_jobs, v_instance_count);

    FOR schema_rec IN schema_cursor LOOP
        -- Job name can be only 32 characters long
        v_job_name := SUBSTR(LOWER('dbx_stats_' || schema_rec.username ),1,32);

        IF v_cluster THEN
            -- Assign instance number for job
            v_node_id := MOD(v_all_jobs, v_instance_count) + 1;
            debugging('v_all_jobs: '|| v_all_jobs);
            debugging('submit next job to inst_id: '|| v_node_id);
        END IF;

        -- Log job start time
        v_start_time := SYSTIMESTAMP;

        debugging('gather_schema_stats: Submitting job for schema: ' || schema_rec.username || ', Job name: ' || v_job_name);

        -- Insert initial job record
        debugging('Insert initial job record');
        insert_job_record(g_session_id, schema_rec.username, v_job_name, v_node_id, v_session_id);

        -- Create the job (but do not enable it yet)
        create_gather_job(v_job_name, schema_rec.username, v_node_id, v_max_job_runtime, g_session_id, p_degree);

    END LOOP;

    -- sleep
    -- DBMS_SESSION.SLEEP(2);

    -- Wait for all jobs to complete
    LOOP
        v_running_jobs := 0;
        FOR rec IN (SELECT COUNT(*) AS running_jobs 
                    FROM gv$session 
                    WHERE client_info = 'dbx_stats_client' 
                    AND module = 'dbx_stats_module' 
                    AND action LIKE 'Schema%'
                    AND CLIENT_IDENTIFIER = g_session_id) LOOP
            v_running_jobs := rec.running_jobs;
        END LOOP;
    
        EXIT WHEN v_running_jobs = 0;

        DBMS_SESSION.SLEEP(20); -- Wait before the next check
    END LOOP;

    -- Log overall duration and number of schemas processed
    v_end_time := SYSTIMESTAMP;
    v_duration := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('Overall Duration: ' || TO_CHAR(v_duration, 'HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Total Schemas Processed: ' || v_all_jobs);

    -- Return job status from the log table
    FOR rec IN (SELECT g_session_id, schema_name, job_name, job_status, start_time, duration, instance_number, dbms_scheduler_status, dbms_scheduler_error, dbms_scheduler_info, session_id FROM dbx_job_record_log WHERE session_id = v_session_id) LOOP
        v_job_status.EXTEND;
        v_job_status(v_job_status.COUNT) := dbx_job_record(
            rec.g_session_id,
            rec.schema_name,
            rec.job_name,
            rec.job_status,
            rec.start_time,
            rec.duration,
            rec.instance_number,
            rec.dbms_scheduler_status,
            rec.dbms_scheduler_error,
            rec.dbms_scheduler_info,
            rec.session_id
        );
        PIPE ROW(v_job_status(v_job_status.COUNT));
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in gather_schema_stats: ' || SQLERRM);
        IF is_trace_enabled() THEN
          DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
          DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
        END IF;
  END gather_schema_stats;


    FUNCTION get_job_status RETURN dbx_job_table PIPELINED IS
        v_job_record dbx_job_record;
    BEGIN
        -- Retrieve job status from the log table
        FOR rec IN (SELECT g_session_id, schema_name, job_name, job_status, start_time, duration, instance_number, dbms_scheduler_status, dbms_scheduler_error, dbms_scheduler_info, session_id FROM dbx_job_record_log) LOOP
            v_job_record := dbx_job_record(
                rec.g_session_id,
                rec.schema_name,
                rec.job_name,
                rec.job_status,
                rec.start_time,
                rec.duration,
                rec.instance_number,
                rec.dbms_scheduler_status,
                rec.dbms_scheduler_error,
                rec.dbms_scheduler_info,
                rec.session_id
            );
            PIPE ROW(v_job_record);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_job_status: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END get_job_status;

    -- Procedure to clean up job logs based on retention setting
    PROCEDURE clean_up_job_logs IS
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
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in clean_up_job_logs: ' || SQLERRM);
            IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
            END IF;
    END clean_up_job_logs;

  PROCEDURE update_job_record_instance(
      p_g_session_id VARCHAR2, 
      p_job_name VARCHAR2, 
      p_instance_number NUMBER
  ) IS
  BEGIN
      UPDATE dbx_job_record_log
      SET instance_number = p_instance_number
      WHERE job_name = LOWER(p_job_name)
      AND g_session_id = p_g_session_id;

      COMMIT;
  EXCEPTION
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error in update_job_record_instance: ' || SQLERRM);
          IF is_trace_enabled() THEN
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
              DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
          END IF;
          ROLLBACK;
  END update_job_record_instance;

  PROCEDURE watch_jobs(v_g_session_id VARCHAR2, v_max_parallel_jobs number, v_instance_count NUMBER) IS
    v_max_runtime        NUMBER;
    v_max_job_runtime    NUMBER;
    v_duration           INTERVAL DAY TO SECOND;
    v_status             VARCHAR2(30);
    v_error              NUMBER;
    v_info               VARCHAR2(4000);
    v_current_status     VARCHAR2(30);
    v_job_completed      BOOLEAN := TRUE;
    v_job_status         VARCHAR2(30);
    v_auto_drop          BOOLEAN;
    v_purge_log          BOOLEAN;
    v_min_instance       NUMBER;
    v_min_job_count      NUMBER;
    v_running_jobs       NUMBER;
  BEGIN
    v_max_runtime := TO_NUMBER(dbx_stats_manager('max_runtime').get_setting) * 60; -- Convert hours to minutes
    v_max_job_runtime := TO_NUMBER(dbx_stats_manager('max_job_duration').get_setting) * 60 + 1; -- Convert hours to minutes and add a few ticks

    -- Get the settings for auto_drop and purge_log
    v_auto_drop := (lower(dbx_stats_manager('job_auto_drop').get_setting) = lower('TRUE'));
    v_purge_log := (lower(dbx_stats_manager('job_purge_log').get_setting) = lower('TRUE'));

    LOOP
        DBMS_SESSION.SLEEP(15);
        v_job_completed := TRUE;

        FOR rec IN (
            SELECT 
                jrl.schema_name, 
                jrl.job_name, 
                jrl.start_time, 
                jrl.job_status, 
                rsj.status, 
                rsj.log_id,
                rsj.error#, 
                rsj.additional_info,
                CASE 
                    WHEN drj.job_name IS NOT NULL THEN 'RUNNING'
                    ELSE 'NOT RUNNING'
                END AS current_status
            FROM 
                dbx_job_record_log jrl
            LEFT JOIN 
                dba_scheduler_running_jobs drj 
                ON lower(jrl.job_name) = lower(drj.job_name)
            LEFT JOIN 
                dba_scheduler_job_run_details rsj 
                ON lower(jrl.job_name) = lower(rsj.job_name) 
                AND rsj.log_id IN (
                    SELECT max(log_id) 
                    FROM dba_scheduler_job_run_details 
                    WHERE lower(job_name) = lower(jrl.job_name)
                )
            WHERE 
                jrl.job_status NOT IN ('COMPLETED', 'STOPPED') 
                AND jrl.g_session_id = v_g_session_id
        ) LOOP
            v_job_completed := FALSE;
            v_job_status := rec.job_status;

            -- Check if overall max_runtime is exceeded
            IF (EXTRACT(MINUTE FROM (SYSTIMESTAMP - rec.start_time))) > v_max_runtime THEN
                DBMS_SCHEDULER.DROP_JOB(job_name => rec.job_name, defer => FALSE, force => TRUE);
                -- Update job record to STOPPED with additional details
                v_duration := SYSTIMESTAMP - rec.start_time;
                v_job_status := 'STOPPED';
                update_job_record(v_g_session_id, rec.job_name, v_job_status, v_duration, rec.status, rec.error#, rec.additional_info);
            END IF;

            -- Check if individual job max_job_runtime is exceeded
            IF (EXTRACT(MINUTE FROM (SYSTIMESTAMP - rec.start_time))) > v_max_job_runtime THEN
                DBMS_SCHEDULER.DROP_JOB(job_name => rec.job_name, defer => FALSE, force => TRUE);
                -- Update job record to STOPPED with additional details
                v_duration := SYSTIMESTAMP - rec.start_time;
                v_job_status := 'STOPPED';
                update_job_record(v_g_session_id, rec.job_name, v_job_status, v_duration, rec.status, rec.error#, rec.additional_info);
            END IF;

            DBMS_SESSION.SLEEP(10);
            -- Check if job is not running anymore and update the log table
            IF rec.current_status = 'NOT RUNNING' THEN
                v_duration := SYSTIMESTAMP - rec.start_time;
                v_job_status := 'COMPLETED';
                update_job_record(v_g_session_id, rec.job_name, v_job_status, v_duration, rec.status, rec.error#, rec.additional_info);

                -- Drop the job if auto drop is enabled
                IF v_auto_drop THEN
                    drop_job(rec.job_name);
                END IF;

                -- Purge the log if purge log is enabled
                IF v_purge_log THEN
                    purge_log(rec.job_name);
                END IF;

            END IF;

            -- Check if any jobs are queued and can be run
            SELECT COUNT(*)
            INTO v_running_jobs
            FROM dba_scheduler_running_jobs
            WHERE owner = USER
            AND JOB_NAME != 'D__WATCHER__D';

            IF v_running_jobs < v_max_parallel_jobs * v_instance_count THEN
                -- Get the next queued job and the instance with the least jobs running
                FOR rec IN (SELECT job_name 
                            FROM dba_scheduler_jobs 
                            WHERE owner = USER 
                            AND job_name LIKE 'DBX_STATS_%' 
                            AND enabled = 'FALSE'
                            AND rownum = 1) LOOP

                    SELECT inst_id, COUNT(*)
                    INTO v_min_instance, v_min_job_count
                    FROM gv$session
                    WHERE client_info = 'dbx_stats_client'
                    GROUP BY inst_id
                    ORDER BY COUNT(*)
                    FETCH FIRST 1 ROWS ONLY;
                    
                    DBMS_SCHEDULER.SET_ATTRIBUTE(rec.job_name, 'INSTANCE_ID', v_min_instance);
                    DBMS_SCHEDULER.ENABLE(rec.job_name);
                    update_job_record_instance(v_g_session_id, rec.job_name, v_min_instance);
                    
                    -- Update the job record to RUNNING status
                    update_job_record(v_g_session_id, rec.job_name, 'RUNNING');

                    EXIT;
                END LOOP;
            END IF;
        END LOOP;

        -- Exit the loop if all jobs are completed or stopped
        IF v_job_completed THEN
            EXIT;
        END IF;

        -- Wait before the next check
        DBMS_SESSION.SLEEP(60);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in watch_jobs: ' || SQLERRM);
        IF is_trace_enabled() THEN
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
        END IF;
  END watch_jobs;

  -- Procedure to enable automatic statistics collection
  PROCEDURE enable(
      p_schema_name  VARCHAR2,
      p_degree       INTEGER,
      p_force        BOOLEAN DEFAULT TRUE,
      p_auto_task    BOOLEAN DEFAULT FALSE
  ) IS
      v_debugging_enabled BOOLEAN := is_debugging_enabled();
      v_sql clob;
      v_schedule_setting   VARCHAR2(100);
      v_job_action         VARCHAR2(2000);
      v_job_name           VARCHAR2(128);
      v_schedule_name      VARCHAR2(128);
      v_current_schema     VARCHAR2(30);
      v_days               SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');
  BEGIN
      debugging('Starting enable procedure...');
      v_current_schema := sys_context('userenv', 'current_schema');
  
      -- Set auto_task
      IF p_auto_task THEN
          v_sql := 'BEGIN DBMS_AUTO_TASK_ADMIN.ENABLE(client_name => ''auto optimizer stats collection'', operation => NULL, window_name => NULL); END;';
          execute immediate v_sql;
      ELSE
          v_sql := 'BEGIN DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => ''auto optimizer stats collection'', operation => NULL, window_name => NULL); END;';
          execute immediate v_sql;
      END IF;
  
      FOR i IN 1..v_days.COUNT LOOP
          v_job_name := v_current_schema || '.dbx_' || LOWER(v_days(i));
          v_schedule_name := v_current_schema || '.dbxw_' || LOWER(v_days(i));
          v_schedule_setting := dbx_stats_manager('SCHEDULE_WINDOW_' || UPPER(v_days(i))).get_setting;
  
          IF p_force THEN
              BEGIN
                  DBMS_SCHEDULER.DROP_SCHEDULE(v_schedule_name, FORCE => TRUE);
                  DBMS_SCHEDULER.DROP_JOB(v_job_name, defer => FALSE, force => TRUE);
              EXCEPTION
                  WHEN OTHERS THEN
                      debugging('Schedule ' || v_schedule_name || ' does not exist or cannot be dropped.');
              END;
          END IF;
  
          DBMS_SCHEDULER.CREATE_SCHEDULE(
              schedule_name   => v_schedule_name,
              repeat_interval => v_schedule_setting
          );

          DBMS_SESSION.SLEEP(1);
  
          v_job_action := 'DECLARE ' ||
                'CURSOR result_cursor IS ' ||
                'SELECT schema_name, job_name, job_status, duration, instance_number ' ||
                'FROM TABLE(dbx_stats.gather_schema_stats(''' || p_schema_name || ''', ' || p_degree || ', ''TRUE'')); ' ||
                'v_result_row result_cursor%ROWTYPE; ' ||
                'BEGIN ' ||
                'OPEN result_cursor; ' ||
                'LOOP ' ||
                'FETCH result_cursor INTO v_result_row; ' ||
                'EXIT WHEN result_cursor%NOTFOUND; ' ||
                'DBMS_OUTPUT.PUT_LINE(''Schema: '' || v_result_row.schema_name || '','' || ' ||
                ''', Job Name: '' || v_result_row.job_name || '','' || ' ||
                ''', Status: '' || v_result_row.job_status || '','' || ' ||
                ''', Duration: '' || TO_CHAR(v_result_row.duration, ''HH24:MI:SS'') || '','' || ' ||
                ''', Instance: '' || v_result_row.instance_number); ' ||
                'END LOOP; ' ||
                'CLOSE result_cursor; ' ||
                'END; ';

          DBMS_SCHEDULER.CREATE_JOB(
              job_name        => v_job_name,
              job_type        => 'PLSQL_BLOCK',
              job_action      => v_job_action,
              schedule_name   => v_schedule_name,
              enabled         => TRUE
          );
  
          debugging('Created schedule and job for ' || v_days(i));
      END LOOP;
  
      debugging('Enable procedure completed.');
  END;
    
  PROCEDURE disable(
      p_schema_name  VARCHAR2,
      p_force        BOOLEAN DEFAULT TRUE,
      p_auto_task    BOOLEAN DEFAULT TRUE
  ) IS
      v_sql clob;
      v_debugging_enabled BOOLEAN := is_debugging_enabled();
      v_schedule_name      VARCHAR2(128);
      v_job_name           VARCHAR2(128);
      v_current_schema VARCHAR2(30);
      v_days               SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');
  BEGIN
      debugging('Starting disable procedure...');
      v_current_schema := sys_context('userenv', 'current_schema');
  
      -- Set auto_task
      IF p_auto_task THEN
          v_sql := 'BEGIN DBMS_AUTO_TASK_ADMIN.ENABLE(client_name => ''auto optimizer stats collection'', operation => NULL, window_name => NULL); END;';
          execute immediate v_sql;
      ELSE
          v_sql := 'BEGIN DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => ''auto optimizer stats collection'', operation => NULL, window_name => NULL); END;';
          execute immediate v_sql;
      END IF;
  
      FOR i IN 1..v_days.COUNT LOOP
          v_schedule_name := v_current_schema||'.dbxw_' || LOWER(v_days(i));
          v_job_name := v_current_schema||'.dbx_' || LOWER(v_days(i));
  
          IF p_force THEN
              BEGIN
                  DBMS_SCHEDULER.DROP_SCHEDULE(v_schedule_name, FORCE => TRUE);
                  DBMS_SCHEDULER.DROP_JOB(v_job_name, DEFER => FALSE, FORCE => TRUE);
              EXCEPTION
                  WHEN OTHERS THEN
                      debugging('Schedule or job ' || v_schedule_name || ' does not exist or cannot be dropped.');
              END;
          END IF;
  
          debugging('Dropped schedule and job for ' || v_days(i));
      END LOOP;
  
      debugging('Disable procedure completed.');
  END;

  
END dbx_stats;
/
