python OALWrapper
====================

This is a pythonic OpenAL library based on OALWrapper by FrictionalGames. Highlights:

- supports loading or streaming wav and ogg files
- 3d positioning, velocity, sound cone orientation
- Environmental reverb
- filters

This does not attempt to expose OALWrapper 1:1, but instead gives more pythonic interface (e.g. function_name instead of FunctionName etc).

Compiling
=========

To compile you need OALWrapper_, libvorbis, libogg and cython. Edit setup.py to set library paths appropriate for your system and run ``setup.py build``.

.. _OALWrapper: https://github.com/FrictionalGames/OALWrapper

License
=======

This code is under the zlib license. See LICENSE file for more information on terms of use.
