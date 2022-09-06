if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES
        plugin-base-disable-no-unused.patch
        plugins-base-x11.patch
        plugins-ugly-disable-doc.patch
    )
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.20.3
    SHA512 f3f2e27e64af615e687419c350216f975be2a6115cd66ac25c4a488bad1e3b7ba2a9f4a9d0d68293cdccfc23abf6bbbd4513e2719778b6189fd43ae89da52b07
    HEAD_REF master
    PATCHES
        gstreamer-disable-hot-doc.patch
        fix-clang-cl.patch
        fix-clang-cl-gstreamer.patch
        fix-clang-cl-base.patch
        fix-clang-cl-good.patch
        fix-clang-cl-bad.patch
        fix-clang-cl-ugly.patch
        gstreamer-disable-no-unused.patch
        ${PATCHES}
)

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

if ("gpl" IN_LIST FEATURES)
    set(LICENSE_GPL enabled)
else()
    set(LICENSE_GPL disabled)
endif()

if ("gpl" IN_LIST FEATURES AND "x264" IN_LIST FEATURES)
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

if ("x11" IN_LIST FEATURES)
    set(PLUGIN_BASE_X11 enabled)
else()
    set(PLUGIN_BASE_X11 disabled)
endif()

if ("opus" IN_LIST FEATURES)
    set(PLUGIN_BASE_OPUS enabled)
else()
    set(PLUGIN_BASE_OPUS disabled)
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

if(VCPKG_TARGET_IS_WINDOWS)
    set(PLUGIN_BASE_WIN
        -Dgst-plugins-base:xvideo=disabled
        -Dgst-plugins-base:xshm=disabled
        -Dgst-plugins-base:gl_winsys=win32
        -Dgst-plugins-base:gl_platform=wgl)
    # TODO: gstreamer has a lot of 'auto' options which probably should be controlled by vcpkg!
endif()

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
    SOURCE_PATH "${SOURCE_PATH}"
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
        -Dgst-plugins-base:x11=${PLUGIN_BASE_X11}
        -Dgst-plugins-base:opus=${PLUGIN_BASE_OPUS}
        ${PLUGIN_BASE_WIN}
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
        -Dgpl=${LICENSE_GPL}
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
if(NOT VCPKG_TARGET_IS_LINUX)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h"
                "${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/libexec"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/include"
                    "${CURRENT_PACKAGES_DIR}/libexec"
                    "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include"
                    "${CURRENT_PACKAGES_DIR}/share/gdb"
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gstconfig.h" "!defined(GST_STATIC_COMPILATION)" "0")
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

# vcpkg errors if pkgconfig files aren't in the standard directory, so we move them to keep it happy.
# This may make it easier to unintentionally find and link plugins into an application.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB DBG_PLUGIN_PCS RELATIVE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/*.pc")
    file(GLOB REL_PLUGIN_PCS RELATIVE "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/*.pc")

    foreach(PC ${DBG_PLUGIN_PCS})
        debug_message("Moving ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/${PC} -> ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PC}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/${PC}" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PC}")
    endforeach()
    foreach(PC ${REL_PLUGIN_PCS})
        debug_message("Moving ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/${PC} -> ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PC}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/${PC}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PC}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
