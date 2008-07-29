#!/usr/bin/env python
# -*- coding: utf8 -*-

from setuptools import setup

setup(
  name = 'TracDiscussion',
  version = '0.5',
  packages = ['tracdiscussion', 'tracdiscussion.db'],
  package_data = {'tracdiscussion' : ['templates/*.cs', 'htdocs/css/*.css']},
  entry_points = {'trac.plugins': ['TracDiscussion.core = tracdiscussion.core',
    'TracDiscussion.init = tracdiscussion.init',
    'TracDiscussion.wiki = tracdiscussion.wiki',
    'TracDiscussion.timeline = tracdiscussion.timeline',
    'TracDiscussion.admin = tracdiscussion.admin',
    'TracDiscussion.search = tracdiscussion.search',
    'TracDiscussion.notification = tracdiscussion.notification']},
  install_requires = ['TracWebAdmin'],
  keywords = 'trac discussion',
  author = 'Alec Thomas, Radek Bartoň',
  author_email = 'trac-hacks@swapoff.org',
  url = 'http://trac-hacks.swapoff.org/wiki/DiscussionPlugin',
  description = 'Discussion forum plugin for Trac',
  license = '''
Copyright (c) 2005, Alec Thomas
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the <ORGANIZATION> nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''
)
