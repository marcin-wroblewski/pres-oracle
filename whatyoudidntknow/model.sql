set pagesize 100
set echo on
set pause on
drop table t_days;
create table t_days ( day_col varchar2(30), val number);
insert into t_days  values ('MONDAY',10);
insert into t_days  values ('TUESDAY',20);
insert into t_days  values ('WEDNESDAY',30);
insert into t_days  values ('THURSDAY',40);
insert into t_days  values ('FRIDAY',50);
insert into t_days  values ('SATURDAY',60);
insert into t_days  values ('SUNDAY',70);

select day_col, val
from t_days;
select day_col, val
  from t_days 
 model 
 dimension by (day_col)
 measures (val)
  (
    val['WORKING_DAYS'] = sum(val)[day_col not in ('SATURDAY','SUNDAY')],
    val['WEEKEND'] = sum(val)[day_col in ('SATURDAY','SUNDAY')],
    val['WEEK'] = val['WORKING_DAYS'] + val['WEEKEND'],
    val['WEEKEND'] = sum(val)[day_col in ('SATURDAY','SUNDAY')],
    val['MON_WED_FRI'] = val['MONDAY'] + val['WEDNESDAY'] + val['FRIDAY'],
    val['COMPLETE_NONSENSE'] = 3 * val['FRIDAY'] / ( 4 * val['THURSDAY'] )
  );
pause
drop table sales_table;
create table sales_table as
select 'Poland' country, 2010 year, 100 sales from dual
union all
select 'Poland', 2011, 120 from dual
union all
select 'Germany', 2010 year, 120 from dual
union all
select 'Germany', 2011, 90 from dual;
select * from sales_table;
pause dygresja 1: rollup
select country, year, sum(sales)
from sales_table
group by rollup(country, year)
;
pause dygresja 2: cube
select country, year, sum(sales)
from sales_table
group by cube(country, year)
;
pause
select country, year, sales
 from sales_table
 model
  dimension by (country, year)
  measures(sales)
  rules upsert all
  (
  sales[country is ANY, 2012] = avg(sales)[cv(country), year < 2012]
  )
order by country, year;
