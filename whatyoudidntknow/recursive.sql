set echo on
set serveroutput on
set linesize 100
column displayed_name format a10 trunc
column path format a10 trunc
drop table t_hier;
create table t_hier(id number primary key, parent_id number, name varchar2(10));
begin
insert into t_hier values(1, null, 'A');
insert into t_hier values(2, 1, 'B');
insert into t_hier values(3, 2, 'C');
insert into t_hier values(4, 2, 'D');
insert into t_hier values(5, 1, 'E');
insert into t_hier values(6, 1, 'F');
insert into t_hier values(7, 6, 'G');
end;
/
select * from t_hier;

pause
with hier(id, name, lev, path) as (
   select id, name, 1, name
     from t_hier 
    where parent_id is null
   union all
   select this.id, this.name, parent.lev + 1, parent.path || '/' || this.name
     from t_hier this join hier parent on parent.id = this.parent_id
)
select * from hier;
pause
with hier(id, name, lev, path) as (
   select id, name, 1, name
     from t_hier 
    where parent_id is null
   union all
   select this.id, this.name, parent.lev + 1, parent.path || '/' || this.name
     from t_hier this join hier parent on parent.id = this.parent_id
)
search depth first by id set search_order
select path, lpad(name, 3*(lev-1) + length(name)) displayed_name 
from hier
order by search_order;
pause
with hier(id, name, lev, path) as (
   select id, name, 1, name
     from t_hier 
    where parent_id is null
   union all
   select this.id, this.name, parent.lev + 1, parent.path || '/' || this.name
     from t_hier this join hier parent on parent.id = this.parent_id
)
search breadth first by id set search_order
select path, lpad(name, 3*(lev-1) + length(name)) displayed_name 
from hier
order by search_order;
pause
@Sudoku.pck
var s varchar2(81)
column s new_value s
exec :s := '53  7    6  195    98    6 8   6   34  8 3  17   2   6 6    28    419  5    8  79';
pause
exec Sudoku.print(:s);
pause
with x( s, ind ) as
( select sud, instr( sud, ' ' )
  from ( select :s sud from dual )
  union all
  select substr( s, 1, ind - 1 ) || z || substr( s, ind + 1 )
       , instr( s, ' ', ind + 1 )
  from x
     , ( select to_char( rownum ) z
         from dual
         connect by rownum <= 9
       ) z
  where ind > 0
  and not exists ( select null
                   from ( select rownum lp
                          from dual
                          connect by rownum <= 9
                        )
                   where z = substr( s, trunc( ( ind - 1 ) / 9 ) * 9 + lp, 1 )
                   or    z = substr( s, mod( ind - 1, 9 ) - 8 + lp * 9, 1 )
                   or    z = substr( s, mod( trunc( ( ind - 1 ) / 3 ), 3 ) * 3
                                      + trunc( ( ind - 1 ) / 27 ) * 27 + lp
                                      + trunc( ( lp - 1 ) / 3 ) * 6
                                   , 1 )
                 )
)
select s
from x
where ind = 0
/
pause
exec :s := '&s';
exec Sudoku.print(:s);
pause
