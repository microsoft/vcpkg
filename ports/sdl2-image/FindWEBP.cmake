# - Try to find WebP.
# Once done, this will define
#
#  WEBP_FOUND - system has WebP.
#  WEBP_INCLUDE_DIRS - the WebP. include directories
#  WEBP_LIBRARIES - link these to use WebP.
#
# Copyright (C) 2012 Raphael Kubo da Costa <rakuco@webkit.org>
# Copyright (C) 2013 Igalia S.L.
# Copyright (C) 2017 Patrick Bader
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND ITS CONTRIBUTORS ``AS
# IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR ITS
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

find_package(PkgConfig)
pkg_check_modules(PC_WEBP QUIET libwebp)

# Look for the header file.
find_path(WEBP_INCLUDE_DIRS
    NAMES webp/decode.h
    HINTS ${PC_WEBP_INCLUDEDIR} ${PC_WEBP_INCLUDE_DIRS}
)
mark_as_advanced(WEBP_INCLUDE_DIRS)

if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    message("debug mode")
endif(CMAKE_BUILD_TYPE MATCHES DEBUG)

# Look for the library.
find_library(WEBP_LIBRARY_RELEASE NAMES webp HINTS ${PC_WEBP_LIBDIR} ${PC_WEBP_LIBRARY_DIRS})
find_library(WEBP_LIBRARY_DEBUG NAMES webpd HINTS ${PC_WEBP_LIBDIR} ${PC_WEBP_LIBRARY_DIRS})

select_library_configurations(WEBP)

mark_as_advanced(WEBP_LIBRARIES)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(WEBP DEFAULT_MSG WEBP_INCLUDE_DIRS WEBP_LIBRARIES)