-- list stale stats on schema level
set serveroutput on

declare
mystaleobjs dbms_stats.objecttab;
begin
-- check whether there is any stale objects
dbms_stats.gather_schema_stats(ownname=>'SCOTT', options=>'LIST STALE',objlist=>
mystaleobjs);
for i in 1 .. mystaleobjs.count loop
dbms_output.put_line(mystaleobjs(i).objname);
end loop;
end;
/

-- check stale stats on database level
set serveroutput on

DECLARE
ObjList dbms_stats.ObjectTab;
BEGIN
dbms_stats.gather_database_stats(objlist=>ObjList, options=>'LIST STALE');
FOR i in ObjList.FIRST..ObjList.LAST
LOOP
dbms_output.put_line(ObjList(i).ownname || '.' || ObjList(i).ObjName || ' ' || ObjList(i).ObjType || ' ' || ObjList(i).partname);
END LOOP;
END;
/


