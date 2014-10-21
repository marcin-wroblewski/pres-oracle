set echo on
set linesize 120
drop table sys_objects;
create table sys_objects ( object_type, object_name, created, last_ddl_time, status, constraint sys_objects_pk primary key(object_type, object_name, created) )
as 
select object_type, object_name, created, LAST_DDL_TIME, status
from dba_objects where owner = 'SYS' and subobject_name is null;
pause
set autotrace traceonly;
select * from sys_objects where object_type = 'PACKAGE' and object_name like 'UTL%';
pause
select object_type, object_name, created from sys_objects where object_type = 'PACKAGE' and object_name like 'UTL%';
pause
drop table sys_objects;
create table sys_objects ( object_type, object_name, created, last_ddl_time, status, constraint sys_objects_pk primary key(object_type, object_name, created) )
organization index
as
select object_type, object_name, created, LAST_DDL_TIME, status
from dba_objects where owner = 'SYS' and subobject_name is null;
pause
select * from sys_objects where object_type = 'PACKAGE' and object_name like 'UTL%';
pause
rem dygresja
alter table sys_objects add constraint sys_objects_obj_type_chk 
check (
object_type in ('CLUSTER',
'CONSUMER GROUP',
'CONTEXT',
'DESTINATION',
'DIRECTORY',
'EDITION',
'EVALUATION CONTEXT',
'FUNCTION',
'INDEX',
'INDEX PARTITION',
'JAVA CLASS',
'JAVA DATA',
'JAVA RESOURCE',
'JAVA SOURCE',
'JOB',
'JOB CLASS',
'LIBRARY',
'LOB',
'LOB PARTITION',
'OPERATOR',
'PACKAGE',
'PACKAGE BODY',
'PROCEDURE',
'PROGRAM',
'QUEUE',
'RESOURCE PLAN',
'RULE',
'RULE SET',
'SCHEDULE',
'SCHEDULER GROUP',
'SEQUENCE',
'SYNONYM',
'TABLE',
'TABLE PARTITION',
'TRIGGER',
'TYPE',
'TYPE BODY',
'UNDEFINED',
'VIEW',
'WINDOW')
);
pause
select * from sys_objects where object_type = 'PACKAGE';
pause
select * from sys_objects where object_type = 'KOPYTKO';
