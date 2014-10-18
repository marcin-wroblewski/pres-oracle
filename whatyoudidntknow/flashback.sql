set echo on
set serveroutput on
set linesize 100
drop table test_flashback;
create table test_flashback (id number primary key, v varchar2(30));
insert into test_flashback (id, v) values (1, 'A');
commit;
select * from test_flashback;
pause
var before_update varchar2(30)
var before_delete varchar2(30);
exec :before_update := to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ss.ff');
pause
update test_flashback set v = 'B' where id = 1 ;
commit;
select * from test_flashback;
pause
exec :before_delete := to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ss.ff');
pause
delete from test_flashback;
commit;
select * from test_flashback;
pause
select * from test_flashback as of timestamp to_timestamp(:before_update, 'yyyy-mm-dd hh24:mi:ss.ff');
pause
select * from test_flashback as of timestamp to_timestamp(:before_delete, 'yyyy-mm-dd hh24:mi:ss.ff');

