set pause off
set echo on
drop table t_hier;
create table t_hier(id number primary key, parent_id number, name varchar2(10));
/*
A
  B
    C
    D
  E
  F
    G
*/
insert into t_hier values(1, null, 'A');
insert into t_hier values(2, 1, 'B');
insert into t_hier values(3, 2, 'C');
insert into t_hier values(4, 2, 'D');
insert into t_hier values(5, 1, 'E');
insert into t_hier values(6, 1, 'F');
insert into t_hier values(7, 6, 'G');
select * from t_hier;
pause
select level, h.name
  from t_hier h
 connect by prior h.id = h.parent_id
 start with h.parent_id is null;
pause
select lpad(h.name, 3*(level-1) + length(h.name)) displayed_name
  from t_hier h
 connect by prior h.id = h.parent_id
 start with h.parent_id is null; 
pause
select sys_connect_by_path(h.name, '/') path
  from t_hier h
 connect by prior h.id = h.parent_id
 start with h.parent_id is null; 
pause select level from dual connect by 1 = 1
