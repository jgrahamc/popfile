From bugs@drunin.net  Wed Jan 29 20:28:35 2003
Return-Path: <bugs@drunin.net>
Delivered-To: run@mail.tepkom.ru
Received: by mail.tepkom.ru (Postfix)
	id 70071971F2; Wed, 29 Jan 2003 20:30:49 +0300 (MSK)
Delivered-To: rescuebre@tepkom.ru
Received: from localhost (localhost [127.0.0.1])
	by mail.tepkom.ru (Postfix) with SMTP
	id 6474D971FA; Wed, 29 Jan 2003 20:30:49 +0300 (MSK)
Received: from keymaster.relativity.com (keymaster.relativity.com [12.146.171.10])
	by mail.tepkom.ru (Postfix) with ESMTP
	id 93510971F2; Wed, 29 Jan 2003 20:30:47 +0300 (MSK)
Received: from rtfm (rtfm.relativity.com [63.100.138.144]) by keymaster.relativity.com with SMTP (Microsoft Exchange Internet Mail Service Version 5.5.2653.13)
	id D4Z7ASMC; Wed, 29 Jan 2003 12:28:21 -0500
To: elia@tepkom.ru, rescuebre@tepkom.ru, kcruz@relativity.com, bugtracker@relativity.com
Date: Wed, 29 Jan 03 12:28:29
From: <bugs@drunin.net>
Subject:  VI ID: 24149  Status: Dev Confirmed Fix  Sev: 1
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="isboundary"
Message-Id: <20030129173047.93510971F2@mail.tepkom.ru>
X-Text-Classification: lists
X-POPFile-Link: <http://127.0.0.1:8080/jump_to_message?view=popfile523=1.msg>

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
      <A href="http://rtfm.relativity.com/VIWeb/default.asp?type=incident&amp;name=24149">24149</A>
      (<A href="http://vi.relativity.com/VIWeb/default.asp?type=incident&amp;name=24149">Alternative server</A>)
    </TD>
    <TD WIDTH="20%"><TD><TD><TD></TR>
  <TBODY>
  <TR>
    <TD><B>Subject:</B></TD>
    <TD COLSPAN=5>Internal error in BRE.dll</TD></TR>
  <TBODY>
  <TR>
    <TD><B>Project:</B></TD>
    <TD COLSPAN=5>/Program/RW/Cobol/BRE/Structure Based</TD></TR>
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
    <TD>Dev Confirmed Fix</TD><TD>
    <TD><B>AssignID:</B></TD>
    <TD>snd</TD>
    <TD>1/29/2003 10:16:01 AM</TD></TR>
  <TR>
    <TD><B>Priority:</B></TD>
    <TD>High</TD><TD>
    <TD><B>RequestID:</B></TD>
    <TD>elia</TD>
    <TD>1/29/2003 10:16:01 AM</TD></TR>
  <TR>
    <TD><B>Severity:</B></TD>
    <TD>1</TD><TD>
    <TD><B>QAID:</B></TD>
    <TD>elia</TD>
    <TD>1/29/2003 10:16:01 AM</TD></TR>
  <TR>
    <TD><B>Category:</B></TD>
    <TD>BRE</TD><TD>
    <TD><B>ChangeID:</B></TD>
    <TD>snd</TD>
    <TD>1/29/2003 12:26:59 PM</TD></TR>
  <TBODY>
  <TR>
    <TD vAlign=top><B>Description:</B></TD>
    <TD COLSPAN=5><TEXTAREA READONLY ROWS=10 COLS=60>FROM:elia DATE:01/29/2003 10:16:01 

     The "Internal error in BRE.dll" message is generated when structure  based slice
     is extracted from program which has been verified with "Perform Program analysis = no"
     and at the same time BRE option "Ensure consistent access to external resources = yes".

     The correct error message should be generated.

     "Severe	Re-verify the program with 'Perform program analysis' option set".


     Test:MEDIUM\\RescueWin\archives\VS-cobol\Computation\Logical-path\CALL-accept4.CBL  

      *|Start paragraph: p1
      *|Last  paragraph: p1

     1015 blue.

FROM:snd DATE:Wednesday, January 29, 2003 11:52:45 AM 

Fixed in Blue. No warning in this case, BRE runs DFA instead.
</TEXTAREA></TD></TR>
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


