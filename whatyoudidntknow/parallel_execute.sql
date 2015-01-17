set echo on
set trims on
set timing off
column task_name format a20 trunc
column status format a15 trunc
column start_rowid format a15 trunc
column end_rowid format a15 trunc
drop table big_tab;
create table big_tab
as 
select * from all_objects
where rownum <= 2000;
pause
create or replace package big_tab_api as
  procedure process_row(p_row in big_tab%rowtype);
  procedure process_big_tab;
end;
/
create or replace package body big_tab_api as
  procedure process_row(p_row in big_tab%rowtype) is
  begin
    dbms_lock.sleep(0.01); 
  end;

  procedure process_big_tab is
  begin
    for r in (select * from big_tab) loop
      process_row(r);
    end loop;
  end;
end;
/
pause
set timing on
exec big_tab_api.process_big_tab();
pause
create or replace package big_tab_api as
  procedure process_row(p_row in big_tab%rowtype);
  procedure process_chunk(p_low_rowid in rowid, p_high_rowid in rowid);
end;
/
create or replace package body big_tab_api as
  procedure process_row(p_row in big_tab%rowtype) is
  begin
    dbms_lock.sleep(0.01);
  end;
  
  procedure process_chunk(p_low_rowid in rowid, p_high_rowid in rowid) is
  begin
    for r in (select *
                from big_tab
               where rowid between p_low_rowid and p_high_rowid) loop
      process_row(r);
    end loop;
  end;
end;
/
pause
begin
  dbms_parallel_execute.create_task('PROCESS BIG_TAB');
  dbms_parallel_execute.create_chunks_by_rowid(
         task_name   => 'PROCESS BIG_TAB',
         table_owner => user,
         table_name  => 'BIG_TAB',
         by_row      => true,
         chunk_size  => 250);
end;
/
pause
begin
  dbms_parallel_execute.run_task(
         task_name      => 'PROCESS BIG_TAB',
         sql_stmt       => 'begin big_tab_api.process_chunk( :start_id, :end_id ); end;',
         language_flag  => DBMS_SQL.NATIVE,
         parallel_level => 8);
end;
/
pause
select task_name, status, start_rowid, end_rowid from dba_parallel_execute_chunks;
pause
begin
  dbms_parallel_execute.drop_task('PROCESS BIG_TAB');
end;
/
