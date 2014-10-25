set echo on
set linesize 120
column constraint_name format a15 trunc
column constraint_type format a2 trunc
column column_name format a15 trunc
column table_name format a15 trunc
column r_constraint_name format a15 trunc
column position format 99 trunc
column foreign_key format a60 trunc
rem Wszystkie tabelki
select table_name from all_tables where owner = 'HR';
pause
rem Wszystkie wiezy integralnosci
select constraint_name, constraint_type, table_name, r_constraint_name
  from all_constraints
 where owner = 'HR';
pause
rem Kolumny wystepujace w wiezach integralnosci
select constraint_name, table_name, column_name, position
  from all_cons_columns where owner = 'HR'
.
pause
/
pause
rem Wiezy integralnosci wraz z kolumnami
select c.constraint_name,
       c.r_constraint_name,
       c.constraint_type,
       c.table_name,
       cc.column_name, 
       cc.position
  from all_constraints c
  join all_cons_columns cc
    on cc.owner = c.owner
   and cc.constraint_name = c.constraint_name
 where c.owner = 'HR'
.
pause
/
pause
alter system flush buffer_cache;
set timing on
rem Raport "klucze obce"
select tabs.table_name,
       case
         when fk_cons.constraint_name is not null then
          rpad(fk_cons.constraint_name || ':', 15) || rpad(fk_cons.column_name, 15) || ' -> ' || uk_cons.table_name || '(' || uk_cons.column_name || ')'
         else ''
       end foreign_key
  from (select table_name from all_tables where owner = 'HR') tabs
  left join (select c.constraint_name,
                    c.r_constraint_name,
                    c.constraint_type,
                    c.table_name,
                    cc.column_name,
                    cc.position
               from all_constraints c
               join all_cons_columns cc
                 on cc.owner = c.owner
                and cc.constraint_name = c.constraint_name
              where c.owner = 'HR'
                and c.constraint_type = 'R') fk_cons
    on fk_cons.table_name = tabs.table_name
  left join (select c.constraint_name,
                    c.r_constraint_name,
                    c.constraint_type,
                    c.table_name,
                    cc.column_name,
                    cc.position
               from all_constraints c
               join all_cons_columns cc
                 on cc.owner = c.owner
                and cc.constraint_name = c.constraint_name
              where c.owner = 'HR'
                and c.constraint_type in ('P', 'U')) uk_cons
    on uk_cons.constraint_name = fk_cons.r_constraint_name
   and uk_cons.position = fk_cons.position
 order by tabs.table_name
.
pause 
/
pause
with 
cons as (
  select c.constraint_name,
         c.r_constraint_name,
         c.constraint_type,
         c.table_name,
         cc.column_name,
         cc.position
    from all_constraints c
    join all_cons_columns cc
      on cc.owner = c.owner
     and cc.constraint_name = c.constraint_name
   where c.owner = 'HR'
),
fk_cons as (
   select * from cons where constraint_type = 'R'
), 
uk_cons as (
   select * from cons where constraint_type in ('P', 'U')
), 
tabs as (
   select table_name from all_tables where owner = 'HR'
)
select tabs.table_name,
       case
         when fk_cons.constraint_name is not null then
          rpad(fk_cons.constraint_name || ':', 15) ||
          rpad(fk_cons.column_name, 15) || ' -> ' || uk_cons.table_name || '(' ||
          uk_cons.column_name || ')'
         else
          ''
       end foreign_key
  from tabs
  left join fk_cons on fk_cons.table_name = tabs.table_name
  left join uk_cons on uk_cons.constraint_name = fk_cons.r_constraint_name and uk_cons.position = fk_cons.position
 order by tabs.table_name
.
pause
/
pause
rem dygresja - materialize
set autotrace on
spool execution_plan.txt
with 
cons as (
  select /*+ materialize */ c.constraint_name,
         c.r_constraint_name,
         c.constraint_type,
         c.table_name,
         cc.column_name,
         cc.position
    from all_constraints c
    join all_cons_columns cc
      on cc.owner = c.owner
     and cc.constraint_name = c.constraint_name
   where c.owner = 'HR'
),
fk_cons as (
   select * from cons where constraint_type = 'R'
), 
uk_cons as (
   select * from cons where constraint_type in ('P', 'U')
), 
tabs as (
   select /*+ materialize */ table_name from all_tables where owner = 'HR'
)
select tabs.table_name,
       case
         when fk_cons.constraint_name is not null then
          rpad(fk_cons.constraint_name || ':', 15) ||
          rpad(fk_cons.column_name, 15) || ' -> ' || uk_cons.table_name || '(' ||
          uk_cons.column_name || ')'
         else
          ''
       end foreign_key
  from tabs
  left join fk_cons on fk_cons.table_name = tabs.table_name
  left join uk_cons on uk_cons.constraint_name = fk_cons.r_constraint_name and uk_cons.position = fk_cons.position
 order by tabs.table_name
.
pause
/
spool off
edit execution_plan.txt
set autotrace off
set timing off
