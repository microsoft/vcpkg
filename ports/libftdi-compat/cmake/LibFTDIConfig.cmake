#                                               -*- cmake -*-
#
#  LibFTDI1Config.cmake(.in)
#
#  Copyright (C) 2013 Intra2net AG and the libftdi developers
#
#  This file is part of LibFTDI.
#
#  LibFTDI is free software; you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License
#  version 2.1 as published by the Free Software Foundation;
#

# Use the following variables to compile and link against LibFTDI:
#  LIBFTDI_FOUND              - True if LibFTDI was found on your system
#  LIBFTDI_USE_FILE           - The file making LibFTDI usable
#  LIBFTDI_DEFINITIONS        - Definitions needed to build with LibFTDI
#  LIBFTDI_INCLUDE_DIRS       - Directory where ftdi.h can be found
#  LIBFTDI_INCLUDE_DIRS       - List of directories of LibFTDI and it's dependencies
#  LIBFTDI_LIBRARY            - LibFTDI library location
#  LIBFTDI_LIBRARIES          - List of libraries to link against LibFTDI library
#  LIBFTDIPP_LIBRARY          - LibFTDI C++ wrapper library location
#  LIBFTDIPP_LIBRARIES        - List of libraries to link against LibFTDI C++ wrapper
#  LIBFTDI_LIBRARY_DIRS       - List of directories containing LibFTDI' libraries
#  LIBFTDI_ROOT_DIR           - The base directory of LibFTDI
#  LIBFTDI_VERSION_STRING     - A human-readable string containing the version
#  LIBFTDI_VERSION_MAJOR      - The major version of LibFTDI
#  LIBFTDI_VERSION_MINOR      - The minor version of LibFTDI
#  LIBFTDI_VERSION_PATCH      - The patch version of LibFTDI
#  LIBFTDI_PYTHON_MODULE_PATH - Path to the python module

set ( LIBFTDI_FOUND 1 )

set ( LIBFTDI_DEFINITIONS  "" )
set ( LIBFTDI_INCLUDE_DIR  "${CMAKE_CURRENT_LIST_DIR}/../../include/libftdi" )
set ( LIBFTDI_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../include/libftdi" )
set ( LIBFTDI_LIBRARY      "${CMAKE_CURRENT_LIST_DIR}/../../lib/ftdi.lib" )
set ( LIBFTDI_LIBRARIES    "${CMAKE_CURRENT_LIST_DIR}/../../lib/ftdi.lib" )
set ( LIBFTDI_STATIC_LIBRARY      "" )
set ( LIBFTDI_STATIC_LIBRARIES    "" )
set ( LIBFTDIPP_LIBRARY    "" )
set ( LIBFTDIPP_LIBRARIES  "" )
set ( LIBFTDI_LIBRARY_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../lib" )
set ( LIBFTDI_ROOT_DIR     "${CMAKE_CURRENT_LIST_DIR}/../.." )

set ( LIBFTDI_VERSION_STRING "0.20" )
set ( LIBFTDI_VERSION_MAJOR  "0" )
set ( LIBFTDI_VERSION_MINOR  "20" )
set ( LIBFTDI_VERSION_PATCH  "" )

set ( LIBFTDI_PYTHON_MODULE_PATH "" )

