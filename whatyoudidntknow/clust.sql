
drop table doc_version;
drop table doc;
drop cluster doc_id;
create cluster doc_id (doc_id number);
create index doc_id_idx on cluster doc_id;
create table doc (id number, filename varchar2(100), doc_type varchar2(1))
cluster doc_id (id);
create table doc_version(id number, doc_id number, content varchar2(2000))
cluster doc_id(doc_id);

insert into doc(id, filename, doc_type)
select rownum, dbms_random.string('l', 20), dbms_random.string('u', 1)
from dual connect by level <= 10000 ;

insert into doc_version(id, doc_id, content)
select rownum
     , mod(abs(dbms_random.random), 10000) + 1
     , dbms_random.string('p', mod(abs(dbms_random.random), 2000) + 1)
from dual
connect by level <= 10000;
     
select versions_count, count(*)
from (
select count(*) versions_count
  from doc join doc_version ver on ver.doc_id = doc.id
group by doc.id
)
group by versions_count
order by 2 desc;

select doc.doc_type, substr(ver.content, 1, 10) content
  from doc join doc_version ver on ver.doc_id = doc.id
 where ver.content like '%a%';
 
