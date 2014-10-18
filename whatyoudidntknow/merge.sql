set echo on
set pagesize 100
drop table object_type_info;
create table object_type_info (object_type varchar2(30) primary key, objects_count number) ;
pause
insert into object_type_info (object_type, objects_count) values ('TABLE', 20);
insert into object_type_info (object_type, objects_count) values ('VIEW', 30);
insert into object_type_info (object_type, objects_count) values ('PACKAGE', 100);
pause
select object_type, count(*) from dba_objects group by object_type order by object_type;
pause
rem Jak tu zaktualizowac object_type_info?
savepoint before_update_insert;
pause
update object_type_info oti
   set objects_count = ( select count(*) from dba_objects o where o.object_type = oti.object_type) ;
pause
insert into object_type_info(object_type, objects_count)
select object_type, count(*) 
from dba_objects 
where object_type not in ( select object_type from object_type_info )
group by object_type ;
pause
select * from object_type_info;
rollback to before_update_insert;
pause
select * from object_type_info;
pause
merge into object_type_info oti
using (select object_type, count(*) obj_count
         from dba_objects
        group by object_type
        order by object_type) obj_types
on (obj_types.object_type = oti.object_type)
when matched then
  update set oti.objects_count = obj_types.obj_count
when not matched then
  insert
    (oti.object_type, oti.objects_count)
  values
    (obj_types.object_type, obj_types.obj_count);
pause
select * from object_type_info;
