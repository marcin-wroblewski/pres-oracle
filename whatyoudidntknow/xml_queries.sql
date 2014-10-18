set echo on
set linesize 120
set pagesize 40
set long 1000
select * from scott.dept;
select * from scott.emp;
pause
select XMLElement("Department",
                  XMLAttributes(d.deptno as "id"),
                  XMLForest(d.dname as "Name", d.loc as "Location")) dept_xml
  from scott.dept d;
pause
select XMLElement("Employee",
                  XMLAttributes(e.empno as "id"),
                  XMLForest(e.ename as "Name",
                            e.hiredate as "HireDate",
                            e.sal as "Salary")) emp_xml
  from scott.emp e;
pause
with employees as (
select e.deptno, XMLElement("Employee",
                  XMLAttributes(e.empno as "id"),
                  XMLForest(e.ename as "Name",
                            e.hiredate as "HireDate",
                            e.sal as "Salary")) emp_xml
 from scott.emp e
)
select XMLAgg(e.emp_xml) emps_list_xml
  from employees e
group by e.deptno;
pause
with employees as
 (select e.deptno,
         XMLElement("Employee",
                    XMLAttributes(e.empno as "id"),
                    XMLForest(e.ename as "Name",
                              e.hiredate as "HireDate",
                              e.sal as "Salary")) emp_xml
    from scott.emp e),
employees_aggregated as
 (select e.deptno, XMLAgg(e.emp_xml) emps_list_xml
    from employees e
   group by e.deptno)
select XMLElement("Department",
                  XMLAttributes(d.deptno as "id"),
                  XMLForest(d.dname as "Name", d.loc as "Location"),
                  XMLElement("Employees", e.emps_list_xml)) dept_xml
  from scott.dept d
  join employees_aggregated e
    on e.deptno = d.deptno;
pause
drop table departments;
create table departments (id primary key, dept_xml)
as
with employees as
 (select e.deptno,
         XMLElement("Employee",
                    XMLAttributes(e.empno as "id"),
                    XMLForest(e.ename as "Name",
                              e.hiredate as "HireDate",
                              e.sal as "Salary")) emp_xml
    from scott.emp e),
employees_aggregated as
 (select e.deptno, XMLAgg(e.emp_xml) emps_list_xml
    from employees e
   group by e.deptno)
select rownum id, XMLElement("Department",
                  XMLAttributes(d.deptno as "id"),
                  XMLForest(d.dname as "Name", d.loc as "Location"),
                  XMLElement("Employees", e.emps_list_xml)) dept_xml
  from scott.dept d
  join employees_aggregated e
    on e.deptno = d.deptno;
pause
desc departments
pause
select to_number(d.dept_xml.extract('/Department/@id')) id
     , cast(d.dept_xml.extract('/Department/Name/text()') as varchar2(30)) name
from departments d;
pause
select d.id department_id, emp.name, emp.hiredate, emp.salary
  from departments d,
       XMLTable('/Department/Employees/Employee' passing d.dept_xml columns name
                varchar2(30) path './Name',
                hiredate date path './HireDate',
                salary number path './Salary') emp;
pause
select d.id department_id, emp.name, emp.hiredate, emp.salary
  from departments d,
       XMLTable('/Department/Employees/Employee[Salary >= 3000]' passing d.dept_xml columns name
                varchar2(30) path './Name',
                hiredate date path './HireDate',
                salary number path './Salary') emp;
