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

    -- Stop POPFile by using startup-script

    do shell script "/Library/StartupItems/POPFile/POPFile stop" with administrator privileges

end if

-- Uninstall POPFile

display dialog "Are you sure to uninstall POPFile? The uninstaller will remove POPFile program, corpus and configuration files from your Mac." buttons {"Cancel", "Uninstall"} default button 1

if the button returned of result is "Uninstall" then

    -- Remove POPFile installation folder and StartupItems folder

    do shell script "rm -rf /Library/POPFile; rm -rf /Library/StartupItems/POPFile" with administrator privileges
end if