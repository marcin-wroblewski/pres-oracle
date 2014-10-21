set echo on
drop table account_history_csv;
drop table account_history;
create table account_history_csv 
(
       accounting_date char(10), 
       operation_date char(10), 
       amount char(10)
)
organization external 
( 
     type oracle_loader 
     default directory EXTERNAL_TAB_DIR
     access parameters 
     (
            records delimited by newline
            fields terminated by ';'
            (
                   accounting_date char(10), 
                   operation_date char(10), 
                   amount char(10)
            )
     )
     location ('account_history.csv')
)
/
pause
select * from account_history_csv;
pause
create table account_history as
select rownum id,
       to_date(operation_date, 'yyyy-mm-dd') operation_date,
       to_number(trim(amount), '99G999D99', 'NLS_NUMERIC_CHARACTERS='', ''') amount
  from account_history_csv
/
pause
select * from account_history where rownum <= 10;
