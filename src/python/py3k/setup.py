#!/usr/bin/env python
from distutils.core import setup


setup(
    name = 'hprose',
    version = '1.2',
    description = 'Hprose is a High Performance Remote Object Service Engine that works over the Internet.',
    author = 'Ma Bingyao',
    url = 'http://www.hprose.com',
    platforms = ['unix', 'linux', 'osx', 'cygwin', 'win32'],
    packages=["hprose", 'fpconst'],
    package_dir=dict(hprose="src/hprose", fpconst="src/fpconst"),
    classifiers=[
        'Development Status :: 1 - Stable',
        'Intended Audience :: Developers',
        'Programming Language :: Python',
        'Topic :: Internet',
        'Topic :: Software Development :: Libraries :: Remote Procedure Call'
    ]
)

