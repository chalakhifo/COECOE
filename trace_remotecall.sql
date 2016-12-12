--for processes who do not log in the table psprcsrqst, they , however, log a line in table PS_MESSAGE_LOG
--then it commits the insert so that the message can be seen in the Process Monitor. A trigger can be created to execute on this insert


CREATE OR REPLACE TRIGGER sysadm.trace_remotecall
BEFORE INSERT ON sysadm.ps_message_log
FOR EACH ROW
WHEN (new.process_instance = 0
AND new.message_seq = 1
AND new.program_name = '&1' -- for example a 'GLPJEDIT' launched online without going through the PSPRCSRQST
AND new.dttm_stamp_sec <= TO_DATE('200407231500','YYYYMMDDHH24MI')
)
BEGIN
EXECUTE IMMEDIATE 'alter session set TIMED_STATISTICS = TRUE';
EXECUTE IMMEDIATE 'alter session set MAX_DUMP_FILE_SIZE = 2048000';
EXECUTE IMMEDIATE 'alter session set TRACEFILE_IDENTIFIER = '''||
replace(:new.program_name,' -','__')||'''';
274 CHAPTER 11 ¦ SQL OPTIMIZATION TECHNIQUES IN PEOPLESOFT
/* disk waits(8) and bind variables(4)*/
EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context
forever, level 8''';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
