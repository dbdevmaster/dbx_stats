set serveroutput on;
DECLARE
    p_schema_name VARCHAR2(128) := '__REGEXP__^EGPDBFRM_DATA';
    v_regexp      VARCHAR2(128);
    v_count       NUMBER;
BEGIN
    IF p_schema_name LIKE '__REGEXP__%' THEN
        v_regexp := lower(substr(p_schema_name, 11));
    END IF;

    SELECT COUNT(username) INTO v_count
    FROM dba_users
    WHERE oracle_maintained = 'N'
        AND ( p_schema_name = '__ALL__' OR ( p_schema_name LIKE '__REGEXP__%' AND REGEXP_LIKE ( lower(username), v_regexp ) )
        OR lower(username) = lower(p_schema_name) );

    dbms_output.put_line('v_regexp: ' || v_regexp);
    dbms_output.put_line('v_count: ' || v_count);
END;
/
