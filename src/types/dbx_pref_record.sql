-- Define the object type for preferences
CREATE OR REPLACE TYPE dbx_pref_record AS OBJECT (
    schema_name VARCHAR2(128),
    object_type VARCHAR2(30),
    object_name VARCHAR2(128),
    partitioned VARCHAR2(1),
    pref_name VARCHAR2(128),
    pref_value VARCHAR2(4000)
);
/

-- Define the table type for preferences
CREATE OR REPLACE TYPE dbx_pref_table AS TABLE OF dbx_pref_record;
/
