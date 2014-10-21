set echo on
set linesize 120
@create_account_history
pause Przyklady funkcji analitycznych
select operation_date "OP. DATE",
       amount,
       sum(amount) over (order by operation_date, id) current_sum,
       first_value(amount) over (partition by trunc(operation_date, 'MON') order by operation_date, id) first_this_month,
       lag(amount) over (order by operation_date, id) previous_amount,
       lead(amount) over (order by operation_date, id) next_amount,
       rank() over (order by abs(amount)) rank
  from account_history 
 order by operation_date, id
.
pause
/
pause Kiedy byla najdluzsza przerwa w uzywaniu konta?
select *
  from (select operation_date,
               amount,
               operation_date - lag(operation_date) over(order by operation_date) days_from_last_operation
          from account_history)
 order by days_from_last_operation desc nulls last;
pause
drop table t_docs;
create table t_docs (id number primary key, name varchar2(30), version number, doc_content varchar2(30));
begin
insert into t_docs values(1, 'document1', 1, 'blah blah blah');
insert into t_docs values(2, 'document1', 2, 'blah blah blah blah');
insert into t_docs values(3, 'document2', 1, 'xxxx');
insert into t_docs values(4, 'document3', 1, '2 + 2 = 3');
insert into t_docs values(5, 'document3', 2, '2 + 2 = 5');
insert into t_docs values(6, 'document3', 3, '2 + 2 = 4');
insert into t_docs values(7, 'document4', 1, 'nothing important');
end;
/
pause Wyciagnij tylko najnowsze wersje dokumentow
select id, name, version, doc_content
  from (select dense_rank() over(partition by name order by version desc) rank_by_version,
               d.*
          from t_docs d)
 where rank_by_version = 1;
