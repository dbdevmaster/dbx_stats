-- Cleanup-script

DECLARE
    CURSOR obj_cursor IS
        SELECT object_name, object_type
        FROM user_objects
        WHERE object_name IN ('PREF_TABLE', 'DBX_PREF_RECORD', 'DBX_STATS', 'DBX_PREFS_MANAGER'
                              , 'DBX_STATS_PREFS', 'DBX_STALE_STATS_RECORD', 'DBX_STALE_STATS_TABLE'
                              , 'DBX_JOB_RECORD', 'DBX_JOB_TABLE', 'DBX_STATS_MANAGER','DBX_STATS_SETTINGS','DBX_JOB_RECORD_LOG','DBX_JOB_MANAGER')
          AND object_type IN ('TYPE', 'PACKAGE', 'PACKAGE BODY', 'TABLE');
    v_sql VARCHAR2(4000);
    v_count NUMBER;

BEGIN
    -- Schleife zum Löschen der benutzerdefinierten Typen, Pakete und Tabelle
    FOR obj_rec IN obj_cursor LOOP
        -- Überprüfen, ob das Objekt existiert
        SELECT COUNT(*) INTO v_count
        FROM user_objects
        WHERE object_name = obj_rec.object_name
          AND object_type = obj_rec.object_type;

        IF v_count > 0 THEN
            IF obj_rec.object_type = 'TYPE' THEN
                v_sql := 'DROP ' || obj_rec.object_type || ' ' || obj_rec.object_name || ' FORCE';
            ELSIF obj_rec.object_type = 'TABLE' THEN
                v_sql := 'DROP ' || obj_rec.object_type || ' ' || obj_rec.object_name || ' CASCADE CONSTRAINTS';
            ELSE
                v_sql := 'DROP ' || obj_rec.object_type || ' ' || obj_rec.object_name;
            END IF;

            BEGIN
                EXECUTE IMMEDIATE v_sql;
                DBMS_OUTPUT.PUT_LINE(obj_rec.object_type || ' ' || obj_rec.object_name || ' gelöscht.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Fehler beim Löschen von ' || obj_rec.object_type || ' ' || obj_rec.object_name || ': ' || SQLERRM);
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE(obj_rec.object_type || ' ' || obj_rec.object_name || ' nicht vorhanden.');
        END IF;
    END LOOP;
    
END;
/

