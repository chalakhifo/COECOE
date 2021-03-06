CREATE OR REPLACE TRIGGER sysadm.connect_trace
AFTER LOGON
ON sysadm.schema
DECLARE
l_tfid VARCHAR2(64);
CHAPTER 11 � SQL OPTIMIZATION TECHNIQUES IN PEOPLESOFT 269
BEGIN
-- if this query returns no rows an exception is raised and trace is not set
SELECT SUBSTR(TRANSLATE(''''
||TO_CHAR(sysdate,'YYYYMMDD.HH24MISS')
||'.'||s.program
||'.'||s.osuser
||''''
,' \/','___'),1,64)
INTO l_tfid
FROM v$session s
WHERE s.sid IN(
SELECT sid
FROM v$mystat
WHERE rownum = 1)
AND UPPER(s.program) LIKE '%PSAPPSRV%';
EXECUTE IMMEDIATE 'ALTER SESSION SET TIMED_STATISTICS = TRUE';
EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE = UNLIMITED';
EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = '||l_tfid;
EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT
FOREVER, LEVEL 8''';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/