# Distributed under the OSI-approved BSD 3-Clause License.
# Copyright Stefano Sinigardi
#
#.rst:
# FindFFMPEG
# --------
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  FFMPEG_FOUND          - True if FFMPEG found on the local system
#  FFMPEG_INCLUDE_DIRD   - Location of FFMPEG header files.
#  FFMPEG_LIBRARIES      - The FFMPEG libraries.
#
# Hints
# ^^^^^
#
# Set ``FFMPEG_ROOT`` to a directory that contains a FFMPEG installation.
#
#

include(FindPackageHandleStandardArgs)

# Macro to find header and lib directories
# example: FFMPEG_FIND(AVFORMAT avformat avformat.h)
MACRO(FFMPEG_FIND varname shortname headername)
    # old version of ffmpeg put header in $prefix/include/[ffmpeg]
    # so try to find header in include directory
    FIND_PATH(FFMPEG_${varname}_INCLUDE_DIRS lib${shortname}/${headername}
        PATHS
        ${FFMPEG_ROOT}/include/lib${shortname}
        $ENV{FFMPEG_DIR}/include/lib${shortname}
        ~/Library/Frameworks/lib${shortname}
        /Library/Frameworks/lib${shortname}
        /usr/local/include/lib${shortname}
        /usr/include/lib${shortname}
        /sw/include/lib${shortname} # Fink
        /opt/local/include/lib${shortname} # DarwinPorts
        /opt/csw/include/lib${shortname} # Blastwave
        /opt/include/lib${shortname}
        /usr/freeware/include/lib${shortname}
        PATH_SUFFIXES ffmpeg
        DOC "Location of FFMPEG Headers"
    )

    FIND_PATH(FFMPEG_${varname}_INCLUDE_DIRS lib${shortname}/${headername}
        PATHS
        ${FFMPEG_ROOT}/include
        $ENV{FFMPEG_DIR}/include
        ~/Library/Frameworks
        /Library/Frameworks
        /usr/local/include
        /usr/include
        /sw/include # Fink
        /opt/local/include # DarwinPorts
        /opt/csw/include # Blastwave
        /opt/include
        /usr/freeware/include
        PATH_SUFFIXES ffmpeg
        DOC "Location of FFMPEG Headers"
    )

    FIND_LIBRARY(FFMPEG_${varname}_LIBRARIES
        NAMES ${shortname}
        PATHS
        ${FFMPEG_ROOT}/lib
        $ENV{FFMPEG_DIR}/lib
        ~/Library/Frameworks
        /Library/Frameworks
        /usr/local/lib
        /usr/local/lib64
        /usr/lib
        /usr/lib64
        /sw/lib
        /opt/local/lib
        /opt/csw/lib
        /opt/lib
        /usr/freeware/lib64
        DOC "Location of FFMPEG Libraries"
    )

    IF (FFMPEG_${varname}_LIBRARIES AND FFMPEG_${varname}_INCLUDE_DIRS)
        SET(FFMPEG_${varname}_FOUND 1)
    ENDIF(FFMPEG_${varname}_LIBRARIES AND FFMPEG_${varname}_INCLUDE_DIRS)

ENDMACRO(FFMPEG_FIND)

SET(FFMPEG_ROOT "$ENV{FFMPEG_DIR}" CACHE PATH "Location of FFMPEG")

# find stdint.h
IF(WIN32)

    FIND_PATH(FFMPEG_STDINT_INCLUDE_DIR stdint.h
        PATHS
        ${FFMPEG_ROOT}/include
        $ENV{FFMPEG_DIR}/include
        ~/Library/Frameworks
        /Library/Frameworks
        /usr/local/include
        /usr/include
        /sw/include # Fink
        /opt/local/include # DarwinPorts
        /opt/csw/include # Blastwave
        /opt/include
        /usr/freeware/include
        PATH_SUFFIXES ffmpeg
        DOC "Location of FFMPEG stdint.h Header"
    )

    IF (FFMPEG_STDINT_INCLUDE_DIR)
        SET(STDINT_OK TRUE)
    ENDIF()

ELSE()

    SET(STDINT_OK TRUE)

ENDIF()

FFMPEG_FIND(libavformat   avformat   avformat.h)
FFMPEG_FIND(libavdevice   avdevice   avdevice.h)
FFMPEG_FIND(libavcodec    avcodec    avcodec.h)
FFMPEG_FIND(libavutil     avutil     avutil.h)
FFMPEG_FIND(libswscale    swscale    swscale.h)  # not sure about the header to look for here.

SET(FFMPEG_FOUND "NO")

# Note we don't check FFMPEG_libswscale_FOUND, FFMPEG_libavdevice_FOUND,
# and FFMPEG_libavutil_FOUND as they are optional.
IF (FFMPEG_libavformat_FOUND AND FFMPEG_libavcodec_FOUND AND STDINT_OK)

    SET(FFMPEG_FOUND "YES")
    SET(FFMPEG_INCLUDE_DIRS ${FFMPEG_libavformat_INCLUDE_DIRS})
    SET(FFMPEG_LIBRARY_DIRS ${FFMPEG_libavformat_LIBRARY_DIRS})

    # Note we hardcode the versions as expected by OpenCV
    set(FFMPEG_libavcodec_VERSION 57.89.100)
    set(FFMPEG_libavformat_VERSION 57.71.100)
    set(FFMPEG_libavutil_VERSION 55.58.100)
    set(FFMPEG_libswscale_VERSION 4.6.100)

    # Note we don't add FFMPEG_LIBSWSCALE_LIBRARIES here,
    # it will be added if found later.
    SET(FFMPEG_LIBRARIES
        ${FFMPEG_libavformat_LIBRARIES}
        ${FFMPEG_libavdevice_LIBRARIES}
        ${FFMPEG_libavcodec_LIBRARIES}
        ${FFMPEG_libavutil_LIBRARIES}
        ${FFMPEG_libswscale_LIBRARIES})
ENDIF()
