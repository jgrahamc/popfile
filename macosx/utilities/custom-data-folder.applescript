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


-- Propaties

property POPFILE_ROOT : "/Library/POPFile"
property POPFILE_USER : ""

--log POPFILE_USER

-- Choose the user folder

if POPFILE_USER is equal to "" then
    try
        choose folder with prompt "Choose your data folder:"
        set POPFILE_USER to result's POSIX path's quoted form
    end try
end if

if POPFILE_USER is not equal to "" then
    --display dialog POPFILE_USER

    -- Run POPFile from the chosen data folder

    do shell script "export POPFILE_ROOT=" & POPFILE_ROOT & "; export POPFILE_USER=" & POPFILE_USER & "; perl -I" & POPFILE_ROOT & "/lib " & POPFILE_ROOT & "/popfile.pl > " & POPFILE_USER & "/console.log 2>&1 &"
end if
