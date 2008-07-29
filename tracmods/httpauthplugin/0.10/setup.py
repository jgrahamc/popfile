#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-

from setuptools import setup

setup(
    name = 'TracHTTPAuth',
    version = '1.1',
    packages = ['httpauth'],
    #package_data = { 'httpauth': ['templates/*.cs', 'htdocs/*.js', 'htdocs/*.css' ] },

    author = "Noah Kantrowitz",
    author_email = "coderanger@yahoo.com",
    description = "Use the AccountManager plugin to provide HTTP authentication from Trac itself.",
    license = "BSD",
    keywords = "trac plugin http auth",
    url = "http://trac-hacks.org/wiki/HttpAuthPlugin",
    classifiers = [
        'Framework :: Trac',
    ],
    
    install_requires = ['TracAccountManager'],

    entry_points = {
        'trac.plugins': [
            'httpauth.filter = httpauth.filter',
        ]
    }
)
