Return-Path: <elia@tepkom.ru>
Delivered-To: run@tepkom.ru
Received: from localhost (localhost [127.0.0.1])
	by mail.tepkom.ru (Postfix) with SMTP id 1D8F4971EC
	for <run@tepkom.ru>; Tue, 21 Jan 2003 01:01:30 +0300 (MSK)
Received: from mta1.wss.scd.yahoo.com (mta1.wss.scd.yahoo.com [66.218.85.32])
	by mail.tepkom.ru (Postfix) with ESMTP id 91A4B971E8
	for <run@tepkom.ru>; Tue, 21 Jan 2003 01:01:28 +0300 (MSK)
Received: from keymaster.relativity.com (12.146.171.10) by mta1.wss.scd.yahoo.com (6.5.032.1)
        id 3E270D860018BFCC for bugs@drunin.net; Mon, 20 Jan 2003 13:59:26 -0800
Message-ID: <3E270D860018BFCC@mta1.wss.scd.yahoo.com> (added by postmaster@mail.san.yahoo.com)
Received: from rtfm (rtfm.relativity.com [63.100.138.144]) by keymaster.relativity.com with SMTP (Microsoft Exchange Internet Mail Service Version 5.5.2653.13)
	id DKF9F5YP; Mon, 20 Jan 2003 16:59:22 -0500
To: rescuebre@tepkom.ru, bugs@drunin.net, kcruz@relativity.com, bugtracker@relativity.com
Date: Mon, 20 Jan 03 16:59:20
From: <elia@tepkom.ru>
Subject: VI ID: 24052  Status: Open  Sev: 2
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="isboundary"
X-Text-Classification: work
X-POPFile-Link: http://127.0.0.1:8080/jump_to_message?view=popfile1043193600_48.msg

--isboundary
Content-Type: text/html; charset=us-ascii

<HTML><HEAD>
<BODY>
<DIV><B><FONT size=4>Visual Intercept Notification:</FONT></B></DIV><BR>
<TABLE border rules=groups>
  <TBODY>
  <TR>
    <TD><B>Incident:</B></TD>
    <TD>
      <A href="http://rtfm.relativity.com/VIWeb/default.asp?type=incident&amp;name=24052">24052</A>
      (<A href="http://vi.relativity.com/VIWeb/default.asp?type=incident&amp;name=24052">Alternative server</A>)
    </TD>
    <TD WIDTH="20%"><TD><TD><TD></TR>
  <TBODY>
  <TR>
    <TD><B>Subject:</B></TD>
    <TD COLSPAN=5>The unnecessary statements are kept in comp. slice.</TD></TR>
  <TBODY>
  <TR>
    <TD><B>Project:</B></TD>
    <TD COLSPAN=5>/Program/RW/Cobol/BRE/Computation Based</TD></TR>
  <TR>
    <TD><B>Version:</B></TD>
    <TD COLSPAN=5>7.1.00</TD></TR>
  <TR>
    <TD><B>Release:</B></TD>
    <TD COLSPAN=5></TD></TR>
  <TR>
    <TD><B>Build:</B></TD>
    <TD COLSPAN=5></TD></TR>
  <TBODY>
  <TR>
    <TD><B>Customer:</B></TD>
    <TD COLSPAN=5>INTERNAL</TD></TR>
  <TBODY>
  <TR>
    <TD><B>Status:</B></TD>
    <TD>Open</TD><TD>
    <TD><B>AssignID:</B></TD>
    <TD>snd</TD>
    <TD>1/20/2003 9:54:00 AM</TD></TR>
  <TR>
    <TD><B>Priority:</B></TD>
    <TD>High</TD><TD>
    <TD><B>RequestID:</B></TD>
    <TD>elia</TD>
    <TD>1/20/2003 9:54:00 AM</TD></TR>
  <TR>
    <TD><B>Severity:</B></TD>
    <TD>2</TD><TD>
    <TD><B>QAID:</B></TD>
    <TD>elia</TD>
    <TD>1/20/2003 9:54:00 AM</TD></TR>
  <TR>
    <TD><B>Category:</B></TD>
    <TD>BRE</TD><TD>
    <TD><B>ChangeID:</B></TD>
    <TD>elia</TD>
    <TD>1/20/2003 9:54:49 AM</TD></TR>
  <TBODY>
  <TR>
    <TD vAlign=top><B>Description:</B></TD>
    <TD COLSPAN=5><TEXTAREA READONLY ROWS=10 COLS=60>

FROM:elia DATE:01/20/2003 09:54:00 
The unnecessary statements are kept in computation slice from GSS.cbl program.

     To reproduce extract comp. slice on "MOVE DOW1 TO DOW".

     The all
     "IF EIBRESP NOT EQUAL DFHRESP(NORMAL)
         PERFORM Z200-ERROR-CONDITION."
 
      statements and several others are unnecessary in comp slice.
      (The "Z200-ERROR-CONDITION"  paragraph is empty in program. Therefore 
     this statements is unnecessary in slice).

     Short test:
     Test:MEDIUM\\RescueWin\archives\VS-cobol\Computation\Logical-path\gss-aux1.cbl 
     
      *|Sliced at SOURCES\COBOL\GSS-AUX1.CBL, line 144, column 12.
      *|DISPLAY DOW 


      The content of the A100-FIRST-TIME is unnecessary.


      BRE default option.

      Program has been verified with
     *|Override CICS Program Terminations: Yes
     Encoding  English
   
     VS-II cobol.
     1002 Blue. (978 - o'k).



     TestProjectID '909',
     project   'VS-GSS', (GSS.cbl program)
     target   'BRECmp',
     with options:
     Override CICS Program Terminations = 'True'
     Support CICS HANDLE statements = 'True'
     Source locale = 'CCSID37'
     Enable Business Rule Extraction = 'true'</TEXTAREA></TD></TR>
  <TR>
    <TD vAlign=top><B>Resolution:</B></TD>
    <TD COLSPAN=5><TEXTAREA READONLY ROWS=10 COLS=60></TEXTAREA></TD></TR>
  <TR>
    <TD vAlign=top><B>WorkAround:</B></TD>
    <TD COLSPAN=5><TEXTAREA READONLY ROWS=10 COLS=60></TEXTAREA></TD></TR></TBODY></TABLE>
<HR>
If you have received this email in error, please respond to: <A 
href="mailto:BugTracker@relativity.com">BugTracker@relativity.com</A> 
<HR>
</BODY></HTML>

--isboundary--
