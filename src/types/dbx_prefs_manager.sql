-- Erstellen des Objekttyps
CREATE OR REPLACE TYPE dbx_prefs_manager AS OBJECT (
    pname VARCHAR2(128),
    enabled CHAR(1),
    STATIC FUNCTION add_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2,
    STATIC FUNCTION delete_pname(p_name VARCHAR2) RETURN VARCHAR2,
    STATIC FUNCTION update_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2
);
/

-- Erstellen des Objekttyps-Körpers
CREATE OR REPLACE TYPE BODY dbx_prefs_manager AS

    STATIC FUNCTION add_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2 IS
    BEGIN
        INSERT INTO dbx_stats_prefs (pname, enabled) VALUES (p_name, p_enabled);
        RETURN 'Added: ' || p_name;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'Error: Duplicate pname - ' || p_name;
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END add_pname;

    STATIC FUNCTION delete_pname(p_name VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        DELETE FROM dbx_stats_prefs WHERE pname = p_name;
        RETURN 'Deleted: ' || p_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Error: pname not found - ' || p_name;
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END delete_pname;

    STATIC FUNCTION update_pname(p_name VARCHAR2, p_enabled CHAR) RETURN VARCHAR2 IS
    BEGIN
        UPDATE dbx_stats_prefs SET enabled = p_enabled WHERE pname = p_name;
        IF SQL%ROWCOUNT = 0 THEN
            RETURN 'Error: pname not found - ' || p_name;
        ELSE
            RETURN 'Updated: ' || p_name;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END update_pname;

END;
/

