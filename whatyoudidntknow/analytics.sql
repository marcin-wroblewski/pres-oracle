set echo on
select operation_date "OP. DATE",
       amount,
       sum(amount) over (order by operation_date, id) current_sum,
       first_value(amount) over (partition by trunc(operation_date, 'MON') order by operation_date, id) first_this_month,
       lag(amount) over (order by operation_date, id) previous_amount,
       rank() over (order by abs(amount)) rank
  from account_history 
 order by operation_date, id

pause
/