Received: (qmail 14017 invoked by uid 417); 13 Feb 2003 20:05:08 -0000
Received: from mail.gentoo.org (HELO gentoo.org) (204.126.2.42)
  by 192.168.0.30 with SMTP; 13 Feb 2003 20:05:08 -0000
Received: (qmail 13859 invoked by uid 1002); 13 Feb 2003 20:10:36 -0000
Mailing-List: contact gentoo-announce-help@gentoo.org; run by ezmlm
Precedence: bulk
List-Post: <mailto:gentoo-announce@gentoo.org>
List-Help: <mailto:gentoo-announce-help@gentoo.org>
List-Unsubscribe: <mailto:gentoo-announce-unsubscribe@gentoo.org>
List-Subscribe: <mailto:gentoo-announce-subscribe@gentoo.org>
List-Id: Gentoo Linux mail <gentoo-announce.gentoo.org>
X-BeenThere: gentoo-announce@gentoo.org
Delivered-To: mailing list gentoo-announce@gentoo.org
Delivered-To: moderator for gentoo-announce@gentoo.org
Received: (qmail 24610 invoked from network); 13 Feb 2003 20:08:14 -0000
Date: Thu, 13 Feb 2003 20:58:33 +0100
From: Sascha Schwabbauer <cybersystem@gentoo.org>
To: gentoo-announce@gentoo.org
Subject: Fix for kde 3.1+3.0.x installs (x86) (bug #15593) - please read
Message-Id: <20030213205833.74db6ea3.cybersystem@gentoo.org>
X-Mailer: Sylpheed version 0.8.9claws (GTK+ 1.2.10; powerpc-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="=.P.GDOi)uP6IbU+"
X-Sender: 320021892970-0001@t-dialin.net

--=.P.GDOi)uP6IbU+
Content-Type: multipart/mixed;
 boundary="Multipart_Thu__13_Feb_2003_20:58:33_+0100_103356a0"


--Multipart_Thu__13_Feb_2003_20:58:33_+0100_103356a0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Hello everyone,

Lots of people have complained that the new kdelibs-3.1-r1 and kdebase-3.1-r1 don't work for them when kde 3.0.x is installed as well: kde 3.1 shows the kde 3.0.x splashscreen and then hangs.

This is due to a misunderstanding: for things to work, you need to install the latest 3.0.5a revisions as well, namely kdelibs-3.0.5a-r2 and kdebase-3.0.5a-r1. Unfortunately portage isn't smart enough to include upgrades of older slots in the world update list. So kde 3.0.x must be upgraded manually to these newer revisions, or things will break.

A quick fix for the problem if you don't want to spend hours compiling right now is to edit /etc/env.d/65kdelibs-3.0.5a (or 65kdelibs-$ver for any older 3.0.x version $ver). Remove the line that says KDEDIRS=/usr/kde/3. Run env-update and restart kdm.

I apologize for the problems this must have caused. I hope this will be
a swift fix.

-- 
Sascha Schwabbauer
Developer / Mailadmin
Gentoo Linux
http://www.gentoo.org/~cybersystem

PGP Key:
http://pgp.mit.edu:11371/pks/lookup?op=get&search=0x84EA0C8F
Key fingerprint = 4BDD CC71 DBDB 58A5 78D0  3382 1EF6 2E96 84EA 0C8F

--Multipart_Thu__13_Feb_2003_20:58:33_+0100_103356a0
Content-Type: application/pgp-signature;
 name="00000000.mimetmp"
Content-Disposition: attachment;
 filename="00000000.mimetmp"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMi4xIChHTlUv
TGludXgpCgppRDhEQlFFK1M5d1hIdll1bG9UcURJOFJBc1dXQUtDREVScGxBSVpiYjZqOCtLa2pG
VlFQOTJFUGxnQ2ZYZ0NRCk43Vy9DdllLTWlremhHRXBnMlZKeWVVPQo9WUJYTgotLS0tLUVORCBQ
R1AgU0lHTkFUVVJFLS0tLS0KCg==

--Multipart_Thu__13_Feb_2003_20:58:33_+0100_103356a0--

--=.P.GDOi)uP6IbU+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+S/jsHvYuloTqDI8RAruvAJ9WJYyAj7TJS+VcoHpzzxunA2FvAwCgou52
PGRJS7+9aI7Uu4FDeZX5c3I=
=hVlT
-----END PGP SIGNATURE-----

--=.P.GDOi)uP6IbU+--
