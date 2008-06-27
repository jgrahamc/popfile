-- Copyright (c) John Graham-Cumming
--
--   This file is part of POPFile
--
--   POPFile is free software; you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation; either version 2 of the License, or
--   (at your option) any later version.
--
--   POPFile is free software; you can redistribute it and/or modify it
--   under the terms of version 2 of the GNU General Public License as
--   published by the Free Software Foundation.
--
--   You should have received a copy of the GNU General Public License
--   along with POPFile; if not, write to the Free Software
--   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
--


-- POPFile is already started?

do shell script "ps -axww | grep popfile.pl | grep -v grep | awk '{print $1}'"
set pid to result

if pid is not "" then
    display dialog "POPFile is already started. (pid = " & pid & ")"
else

    -- Start POPFile by using startup-script

    do shell script "/Library/StartupItems/POPFile/POPFile start" with administrator privileges
end if
