set echo on
set trims on
drop function product;
drop type Product_Impl;
drop table t_numbers;
create table t_numbers(num number);
insert into t_numbers values(1);
insert into t_numbers values(2);
insert into t_numbers values(3);
insert into t_numbers values(4);
insert into t_numbers values(5);
select * from t_numbers;
pause
select sum(num) from t_numbers;
pause
select product(num) from t_numbers;
pause
--oczywiscie mozna zawsze cos wykombinowac
select exp(sum(ln(num))) from t_numbers;
pause
--ale nie w tym rzecz
--chcemy zrobic cos podobnego do:
/*
		List<Integer> numbers = Arrays.asList(1,2,3,4,5);
		System.out.println(numbers.stream().reduce(1, (a, b) -> a * b));
*/
pause
create or replace type Product_Impl as object
(
  total_product number,

  static function ODCIAggregateInitialize(aggr_context IN OUT Product_Impl)
    return number,

  member function ODCIAggregateIterate(self  IN OUT Product_Impl,
                                       value IN number) return number,

  member function ODCIAggregateTerminate(self        IN Product_Impl,
                                         returnValue OUT number,
                                         flags       IN number) return number,

  member function ODCIAggregateMerge(self IN OUT Product_Impl,
                                     second_aggr_context IN Product_Impl) return number
)
/
pause
create or replace type body Product_Impl as 
  static function ODCIAggregateInitialize(aggr_context IN OUT Product_Impl)
    return number
  is
  begin
    aggr_context := Product_Impl(1);
    return ODCIConst.Success;
  end;
 
  member function ODCIAggregateIterate(self  IN OUT Product_Impl,
                                       value IN number) return number
  is
  begin
    self.total_product := self.total_product * value;
    return ODCIConst.Success;
  end;
  
  member function ODCIAggregateTerminate(self        IN Product_Impl,
                                         returnValue OUT number,
                                         flags       IN number) return number
  is
  begin
    returnValue := self.total_product;
    return ODCIConst.Success;
  end;
  -- potrzebny do rownoleglego agregowania
  member function ODCIAggregateMerge(self IN OUT Product_Impl,
                                     second_aggr_context IN Product_Impl) return number
  is
  begin
    self.total_product := self.total_product * second_aggr_context.total_product;
    return ODCIConst.Success;
  end;
end;
/
pause
create function product(input number) return number 
       parallel_enable aggregate using Product_Impl;
/
pause
select product(num) from t_numbers;
pause
select product(num) over(order by num) from t_numbers;
pause
with nums as (
select case mod(num, 2)
         when 0 then
          'EVEN'
         else
          'ODD'
       end parity,
       num
  from t_numbers
)
select parity, product(num)
from nums
group by parity;
