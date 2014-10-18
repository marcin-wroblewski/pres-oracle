set echo on
drop table t_tokens;
create table t_tokens (token varchar2(100));

create or replace and compile java source named DeepThought as
package marcin.storedproc;

public class DeepThought {
  private static final int HALF_AND_MILLION_YEARS = 5000;

  public static int answerUltimateQuestionOfLifeTheUniverseAndEverything()
			throws InterruptedException {
		Thread.sleep(HALF_AND_MILLION_YEARS);

		return 42;
	}
}
/
pause
create or replace and compile java source named MoreSophisticatedOne as
package marcin.storedproc;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;

import oracle.jdbc.driver.OracleDriver;

public class MoreSophisticatedOne {
  private static OracleDriver driver = new OracleDriver();

	public static void splitAndInsert(String csv) throws SQLException {
		Connection connection = driver.defaultConnection();
		PreparedStatement insertStmt = connection
				.prepareStatement("insert into t_tokens(token) values(?)");

		for (String token : Arrays.asList(csv.split(","))) {
			insertStmt.setString(1, token);
			insertStmt.execute();
		}

		insertStmt.close();
	}
}
/
pause
drop package java_stored_procs
/
create package java_stored_procs as
   function AnswrUltmtQstnOfLifUnvEvrthg return number;
   procedure split_and_insert(p_csv in varchar2);
end;
/
pause
create package body java_stored_procs as
   function AnswrUltmtQstnOfLifUnvEvrthg return number
     is language java name 'marcin.storedproc.DeepThought.answerUltimateQuestionOfLifeTheUniverseAndEverything() return int';

   procedure split_and_insert(p_csv in varchar2)
     is language java name 'marcin.storedproc.MoreSophisticatedOne.splitAndInsert(java.lang.String)';
end;
/
pause
select java_stored_procs.AnswrUltmtQstnOfLifUnvEvrthg from dual;
pause
begin
  java_stored_procs.split_and_insert('abc,def,ghi');
end;
/
pause
select * from t_tokens;
