CREATE TABLE dbx_stats_prefs (
    pname VARCHAR2(128) PRIMARY KEY,
    enabled CHAR(1) CHECK (enabled IN ('Y', 'N'))
);

