set echo on
drop table debits;
drop table credits;
create table debits (id number primary key, operation_date date, amount number);
create table credits (id number primary key, operation_date date, amount number);
pause
with account_history as
 (select rownum id,
         to_date(operation_date, 'yyyy-mm-dd') operation_date,
         to_number(trim(amount), '99G999D99', 'NLS_NUMERIC_CHARACTERS='', ''') amount
    from account_history_csv)
select id, operation_date, amount from account_history
where rownum <= 10;
pause
insert all 
when (amount < 0) 
     then into debits values(id, operation_date, -amount) 
when (amount > 0) 
     then into credits values (id, operation_date, amount)
with account_history as
 (select rownum id,
         to_date(operation_date, 'yyyy-mm-dd') operation_date,
         to_number(trim(amount), '99G999D99', 'NLS_NUMERIC_CHARACTERS='', ''') amount
    from account_history_csv)
select id, operation_date, amount from account_history;
pause
select * from (select * from debits order by id ) where rownum <= 10;
select * from (select * from credits order by id ) where rownum <= 10;
