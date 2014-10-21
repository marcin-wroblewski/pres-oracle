set echo on
set linesize 120
set pagesize 20
set serveroutput on size 100000
drop table emp;
create table emp as select * from scott.emp;
alter table emp add constraint emp_pk primary key (empno);
select * from emp;
pause
create or replace procedure set_salary(empno     in emp.empno%type,
                                       newsalary in emp.sal%type) is
begin
  update emp e 
     set e.sal = newsalary 
   where e.empno = empno;
end;
/
pause
exec set_salary(7900, 1000);
pause
select * from emp;
pause
rollback;
select * from emp;
pause
variable newsalary number;
exec :newsalary := 1000;
update emp e 
   set e.sal = :newsalary
 where e.empno = empno;
pause
set echo off
@Types.pck
pause
set echo on
declare
  FATAL_ERROR exception;
  
  procedure modify_list(p_list      in out Types.t_strings,
                        i           in binary_integer,
                        new_element in varchar2) is
  begin
    p_list(i) := new_element;

    dbms_output.put_line('inside procedure: list = ' || Types.to_str(p_list));

    raise FATAL_ERROR;
  end;

  procedure test is
    l_list Types.t_strings := Types.t_strings('a', 'b', 'e', 'd');
  begin
    dbms_output.put_line('before: list = ' || Types.to_str(l_list));

    modify_list(l_list, 3, 'c');
  exception
    when FATAL_ERROR then
      dbms_output.put_line('after: list = ' || Types.to_str(l_list));
  end;
  
  
begin
  test();
end;
.
pause
/
pause
declare
  FATAL_ERROR exception;
  
  procedure modify_list(p_list      in out nocopy Types.t_strings,
                        i           in binary_integer,
                        new_element in varchar2) is
  begin
    p_list(i) := new_element;

    dbms_output.put_line('inside procedure: list = ' || Types.to_str(p_list));

    raise FATAL_ERROR;
  end;

  procedure test is
    l_list Types.t_strings := Types.t_strings('a', 'b', 'e', 'd');
  begin
    dbms_output.put_line('before: list = ' || Types.to_str(l_list));

    modify_list(l_list, 3, 'c');

  exception
    when FATAL_ERROR then
      dbms_output.put_line('after: list = ' || Types.to_str(l_list));
  end;
  
  
begin
  test();
end;
.
pause
/
rem NOCOPY is only a hint—each time the subprogram is invoked, the compiler decides, silently, whether to obey or ignore NOCOPY
pause
select TEXT from user_source where name = 'TYPES' and type = 'PACKAGE' order by line;
pause
declare
  l_records Types.t_records := Types.t_records(Types.new_record(1, 'a'),
                                               Types.new_record(2, 'b'));
  l_record Types.t_record;
begin
  l_record := l_records(1);

  dbms_output.put_line('before change: l_record    =' || Types.to_str(l_record));
  dbms_output.put_line('before change: l_records(1)=' || Types.to_str(l_records(1)));

  l_record.numval := 3;
  l_record.stringval := 'c';

  dbms_output.put_line('after change: l_record    =' || Types.to_str(l_record));
  dbms_output.put_line('after change: l_records(1)=' || Types.to_str(l_records(1)));
end;
.
pause
/
pause
declare
  l_text varchar2(100) := '';
begin
  if l_text = '' then
  
     dbms_output.put_line(q'!text = ''!');
  
  elsif l_text <> '' then
  
     dbms_output.put_line(q'!text <> ''!');
  
  else
  
     dbms_output.put_line('What the ...?');
  
  end if;
end;
.
pause
/
pause
drop table strings_tab ;
create table strings_tab (str varchar2(100));
insert into strings_tab values ('abc');
insert into strings_tab values ('def');
insert into strings_tab values ('');
insert into strings_tab values ('ghi');

select * from strings_tab;
pause
select * from strings_tab where str = '';
pause
select * from strings_tab where str <> '';
pause
select * from strings_tab where str is null;
