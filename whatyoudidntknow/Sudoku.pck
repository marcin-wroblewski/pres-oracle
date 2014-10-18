create or replace package Sudoku as
  procedure print(p_sudoku in varchar2);
end;
/
create or replace package body Sudoku as
  procedure p(p_line in varchar2) is
  begin
    dbms_output.put_line(p_line);
  end;

  procedure horizontal_line is
  begin
    p('-------------------');
  end;

  procedure print_row(p_row in varchar2) is
    l_line varchar2(20);
  begin
    l_line := '|';
    for i in 1 .. 9 loop
      l_line := l_line || substr(p_row, i, 1);
      if mod(i, 3) = 0 then
        l_line := l_line || '|';
      else
        l_line := l_line || ' ';
      end if;
    end loop;
    p(l_line);
  end;

  procedure print(p_sudoku in varchar2) is
  begin
    horizontal_line();
    for r in (select substr(p_sudoku, (level - 1) * 9 + 1, 9) sudoku_row,
                     rownum rn
                from dual
              connect by level <= 9) loop
      print_row(r.sudoku_row);
      if mod(r.rn, 3) = 0 then
        horizontal_line();
      end if;
    end loop;
  end;
end;
/
