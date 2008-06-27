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


-- POPFile is running?

do shell script "ps -axww | grep popfile.pl | grep -v grep | awk '{print $1}'"
set pid to result

if pid is not "" then

    -- Get POPFile UI port

    set html_port to do shell script "grep html_port /Library/POPFile/popfile.cfg | awk '{print $2};'"

    -- Open UI

    if html_port is not "" then
        set ui_url to "http://127.0.0.1:" & html_port & "/"

        open location ui_url
    end if

else
    display dialog "POPFile is not running."
end if
