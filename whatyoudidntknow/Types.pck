create or replace package Types is
  type t_strings is table of varchar2(100);
  type t_record is record(
    numval    number,
    stringval varchar2(10));
  type t_records is table of t_record;

  function new_record(p_numval in number, p_stringval in varchar2)
    return t_record;
  function to_str(p_strings in t_strings) return varchar2;
  function to_str(p_record in t_record) return varchar2;
end Types;
/
create or replace package body Types is
  function new_record(p_numval in number, p_stringval in varchar2)
    return t_record is
    l_record t_record;
  begin
    l_record.numval := p_numval;
    l_record.stringval := p_stringval;
    return l_record;
  end;

  function to_str(p_strings in t_strings) return varchar2 is
    i binary_integer;
    l_tostr varchar2(32767);
  begin
    i := p_strings.first();
    while i is not null loop
      l_tostr := l_tostr || p_strings(i) || ',';
      i := p_strings.next(i);
    end loop;
    return '[' || rtrim(l_tostr, ',') || ']';
  end;

  function to_str(p_record in t_record) return varchar2 is
  begin
    return '(' || p_record.numval || ',' || p_record.stringval || ')';
  end;
end Types;
/
