set linesize 120
set echo on
set autotrace off
set timing off
drop table t;
create table t as
select o.*
  from all_objects o
;
insert into t select * from t;
insert into t select * from t;
pause
desc t;
pause
select secondary, count(*)
  from t  
 group by secondary;
pause
create index t_secondary_idx on t (secondary);
pause
set autotrace traceonly
set timing on
var v_secondary varchar2(1)
exec :v_secondary := 'N';
pause
select * from t where secondary = :v_secondary;
pause
exec :v_secondary := 'Y';
pause
select * from t where secondary = :v_secondary;
pause
select * from t where secondary = 'N';
pause
