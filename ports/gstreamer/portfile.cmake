vcpkg_from_github(
    OUT_SOURCE_PATH GST_BUILD_SOURCE_PATH
    REPO gstreamer/gst-build
    REF 1.19.2
    SHA512 d6b8e9fc195a60dfb83fe8a49040c21ca5603e3ada2036d56851e6e61a1cd2653ad45f33e39388bde859dfb4806f4a60d9dbfac5fe41b6d2a8b395c44d4525e3
    HEAD_REF master
    PATCHES gstreamer-disable-hot-doc.patch
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.19.2
    SHA512 6070f1febf2a1bcc6e68f1e03c1b76891db210773065696e26fac20f0bd3ff47e1634222a49f93a10f6e47717ff21084c9ae0feed6a20facb9650aeb879cc380
    HEAD_REF master
    PATCHES gstreamer-disable-no-unused.patch
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PLUGIN_BASE_PATCHES plugins-base-use-zlib.patch plugin-base-disable-no-unused.patch)
    list(APPEND PLUGIN_GOOD_PATCHES plugins-good-use-zlib.patch)
    list(APPEND PLUGIN_UGLY_PATCHES plugins-ugly-disable-doc.patch)
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_BASE_SOURCE_PATH
    REPO gstreamer/gst-plugins-base
    REF 1.19.2
    SHA512 d2005e6a3bda5f08395b131347e8f4054c2469e04e65d1acc1a1572bf10d81d4dad4e43d6a8600346b6175a2310f81157a0cd27398ef69b5363b16346febfb39
    HEAD_REF master
    PATCHES ${PLUGIN_BASE_PATCHES}
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_GOOD_SOURCE_PATH
    REPO gstreamer/gst-plugins-good
    REF 1.19.2
    SHA512 71e9f36d407db3b75d9a68f6447093aa011b2b586b06e0a1bb79c7db37c9114de505699e99a4dad06d8d9c742e91f48dd35457283babe440f88a9e40d3da465b
    HEAD_REF master
    PATCHES ${PLUGIN_GOOD_PATCHES}
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_BAD_SOURCE_PATH
    REPO gstreamer/gst-plugins-bad
    REF 1.19.2
    SHA512 f63ca3abf380bba92dca4ac3a51cba5ea95093693cf64d167a7a9c0bf6341c35a74fd42332673dbd1581ea70da0a35026aa3e2ce99b5e573268ccb55b5491c1d
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_UGLY_SOURCE_PATH
    REPO gstreamer/gst-plugins-ugly
    REF 1.19.2
    SHA512 70dcd4a36d3bd35f680eaa3c980842fbb57f55f17d1453c6a95640709b1b33a263689bf54caa367154267d281e5474686fedaa980de24094de91886a57b6547a
    HEAD_REF master
    PATCHES ${PLUGIN_UGLY_PATCHES}
)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH GST_MESON_PORTS_SOURCE_PATH
    REPO gstreamer/meson-ports/gl-headers
    REF 5c8c7c0d3ca1f0b783272dac0b95e09414e49bc8 # master commit. Date 2021-04-21
    SHA512 d001535e1c1b5bb515ac96c7d15b25ca51460a5af0c858df53b11c7bae87c4a494e4a1b1b9c3c41a5989001db083645dde2054b82acbbeab7f9939308b676f9c
    HEAD_REF master
)

if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gstreamer")
    file(RENAME "${GST_SOURCE_PATH}" "${GST_BUILD_SOURCE_PATH}/subprojects/gstreamer")
endif()
if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-base")
    file(RENAME "${GST_PLUGIN_BASE_SOURCE_PATH}" "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-base")
endif()
if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-good")
    file(RENAME "${GST_PLUGIN_GOOD_SOURCE_PATH}" "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-good")
endif()
if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-bad")
    file(RENAME "${GST_PLUGIN_BAD_SOURCE_PATH}"  "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-bad")
endif()
if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-ugly")
    file(RENAME "${GST_PLUGIN_UGLY_SOURCE_PATH}" "${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-ugly")
endif()
if (NOT EXISTS "${GST_BUILD_SOURCE_PATH}/subprojects/gl-headers")
    file(RENAME "${GST_MESON_PORTS_SOURCE_PATH}" "${GST_BUILD_SOURCE_PATH}/subprojects/gl-headers")
endif()

if(VCPKG_TARGET_IS_OSX)
    # In Darwin platform, there can be an old version of `bison`,
    # Which can't be used for `gst-build`. It requires 2.4+
    vcpkg_find_acquire_program(BISON)
    execute_process(
        COMMAND ${BISON} --version
        OUTPUT_VARIABLE BISON_OUTPUT
    )
    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" BISON_VERSION "${BISON_OUTPUT}")
    set(BISON_MAJOR ${CMAKE_MATCH_1})
    set(BISON_MINOR ${CMAKE_MATCH_2})
    message(STATUS "Using bison: ${BISON_MAJOR}.${BISON_MINOR}.${CMAKE_MATCH_3}")
    if(NOT (BISON_MAJOR GREATER_EQUAL 2 AND BISON_MINOR GREATER_EQUAL 4))
        message(WARNING "'bison' upgrade is required. Please check the https://stackoverflow.com/a/35161881")
    endif()
endif()

# make tools like 'glib-mkenums' visible
get_filename_component(GLIB_TOOL_DIR "${CURRENT_INSTALLED_DIR}/tools/glib" ABSOLUTE)
message(STATUS "Using glib tools: ${GLIB_TOOL_DIR}")
vcpkg_add_to_path(PREPEND "${GLIB_TOOL_DIR}")

if ("x264" IN_LIST FEATURES)
    set(PLUGIN_UGLY_X264 enabled)
else()
    set(PLUGIN_UGLY_X264 disabled)
endif()

if("plugins-base" IN_LIST FEATURES)
    set(PLUGIN_BASE_SUPPORT enabled)
else()
    set(PLUGIN_BASE_SUPPORT disabled)
endif()
if("plugins-bad" IN_LIST FEATURES)
    # requires 'libdrm', 'dssim', 'libmicrodns'
    message(FATAL_ERROR "The feature 'plugins-bad' is not supported in this port version")
    set(PLUGIN_BAD_SUPPORT enabled)
else()
    set(PLUGIN_BAD_SUPPORT disabled)
endif()
if("plugins-ugly" IN_LIST FEATURES)
    set(PLUGIN_UGLY_SUPPORT enabled)
else()
    set(PLUGIN_UGLY_SUPPORT disabled)
endif()

if ("gl-graphene" IN_LIST FEATURES)
    set(GL_GRAPHENE enabled)
else()
    set(GL_GRAPHENE disabled)
endif()

if ("flac" IN_LIST FEATURES)
    set(PLUGIN_GOOD_FLAC enabled)
else()
    set(PLUGIN_GOOD_FLAC disabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBRARY_LINKAGE "shared")
else()
    set(LIBRARY_LINKAGE "static")
endif()

# gst-build's meson configuration needs git. Make the tool visible.
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_DIR}")

#
# check scripts/cmake/vcpkg_configure_meson.cmake
#   --wrap-mode=nodownload
#
# References
#   https://github.com/GStreamer/gst-build/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-base/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-good/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-bad/blob/1.18.4/meson_options.txt
#   https://github.com/GStreamer/gst-plugins-ugly/blob/1.18.4/meson_options.txt
#
vcpkg_configure_meson(
    SOURCE_PATH "${GST_BUILD_SOURCE_PATH}"
    OPTIONS
        # gstreamer
        -Dgstreamer:default_library=${LIBRARY_LINKAGE}
        -Dgstreamer:check=disabled
        -Dgstreamer:libunwind=disabled
        -Dgstreamer:libdw=disabled
        -Dgstreamer:dbghelp=disabled
        -Dgstreamer:bash-completion=disabled
        -Dgstreamer:coretracers=disabled
        -Dgstreamer:examples=disabled
        -Dgstreamer:tests=disabled
        -Dgstreamer:benchmarks=disabled
        -Dgstreamer:tools=disabled
        -Dgstreamer:doc=disabled
        -Dgstreamer:introspection=disabled
        -Dgstreamer:nls=disabled
        # gst-plugins-base
        -Dbase=${PLUGIN_BASE_SUPPORT}
        -Dgst-plugins-base:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-base:examples=disabled
        -Dgst-plugins-base:tests=disabled
        -Dgst-plugins-base:doc=disabled
        -Dgst-plugins-base:tools=disabled
        -Dgst-plugins-base:introspection=disabled
        -Dgst-plugins-base:nls=disabled
        -Dgst-plugins-base:orc=disabled
        -Dgst-plugins-base:pango=disabled
        -Dgst-plugins-base:gl-graphene=${GL_GRAPHENE}
        # gst-plugins-good
        -Dgst-plugins-good:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-good:qt5=disabled
        -Dgst-plugins-good:soup=disabled
        -Dgst-plugins-good:cairo=auto # cairo[gobject]
        -Dgst-plugins-good:speex=auto # speex
        -Dgst-plugins-good:taglib=auto # taglib
        -Dgst-plugins-good:vpx=auto # libvpx
        -Dgst-plugins-good:examples=disabled
        -Dgst-plugins-good:tests=disabled
        -Dgst-plugins-good:doc=disabled
        -Dgst-plugins-good:nls=disabled
        -Dgst-plugins-good:orc=disabled
        -Dgst-plugins-good:flac=${PLUGIN_GOOD_FLAC}
        # gst-plugins-bad
        -Dbad=${PLUGIN_BAD_SUPPORT}
        -Dgst-plugins-bad:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:opencv=disabled
        -Dgst-plugins-bad:hls-crypto=openssl
        -Dgst-plugins-bad:examples=disabled
        -Dgst-plugins-bad:tests=disabled
        -Dgst-plugins-bad:doc=disabled
        -Dgst-plugins-bad:introspection=disabled
        -Dgst-plugins-bad:nls=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:orc=disabled
        # gst-plugins-ugly
        -Dugly=${PLUGIN_UGLY_SUPPORT}
        -Dgst-plugins-ugly:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-ugly:tests=disabled
        -Dgst-plugins-ugly:doc=disabled
        -Dgst-plugins-ugly:nls=disabled
        -Dgst-plugins-ugly:orc=disabled
        -Dgst-plugins-ugly:x264=${PLUGIN_UGLY_X264}
        # see ${GST_BUILD_SOURCE_PATH}/meson_options.txt
        -Dpython=disabled
        -Dlibav=disabled
        -Dlibnice=disabled # libnice
        -Ddevtools=disabled
        -Dges=disabled
        -Drtsp_server=disabled
        -Domx=disabled
        -Dvaapi=disabled
        -Dsharp=disabled
        -Drs=disabled
        -Dgst-examples=disabled
        -Dtls=disabled
        -Dtests=disabled    # common options
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dnls=disabled
        -Dorc=disabled
        -Ddoc=disabled
        -Dgtk_doc=disabled
        -Ddevtools=disabled
    OPTIONS_DEBUG
        -Dgstreamer:gst_debug=true # plugins will reference this value
    OPTIONS_RELEASE
        -Dgstreamer:gst_debug=false
        -Dgstreamer:gobject-cast-checks=disabled
        -Dgstreamer:glib-asserts=disabled
        -Dgstreamer:glib-checks=disabled
        -Dgstreamer:extra-checks=disabled
        -Dgst-plugins-base:gobject-cast-checks=disabled
        -Dgst-plugins-base:glib-asserts=disabled
        -Dgst-plugins-base:glib-checks=disabled
        -Dgst-plugins-good:gobject-cast-checks=disabled
        -Dgst-plugins-good:glib-asserts=disabled
        -Dgst-plugins-good:glib-checks=disabled
        -Dgst-plugins-bad:gobject-cast-checks=disabled
        -Dgst-plugins-bad:glib-asserts=disabled
        -Dgst-plugins-bad:glib-checks=disabled
)

vcpkg_install_meson()

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KHR"
                    "${CURRENT_PACKAGES_DIR}/include/GL"
)
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h"
            "${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/libexec"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/include"
                    "${CURRENT_PACKAGES_DIR}/libexec"
                    "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin"
                        "${CURRENT_PACKAGES_DIR}/bin"
    )
    set(PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
    set(SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}"
                "${CURRENT_PACKAGES_DIR}/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if (NOT VCPKG_BUILD_TYPE)
        file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.dll"
                           "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb"
        )
        file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.dll"
                       "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${GST_BUILD_SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
