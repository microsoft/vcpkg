vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.19.3
    SHA512 a132b7d3eeae19a1021abf7d5604c212a29039847ec851c8a24b54a60559a4b68c5b4d26c6a2aaac0a4b03c8939fcf4bb1c2716371407cb75bf2e75dab35a805
    HEAD_REF master
    PATCHES fix-package-search.patch
)

# make tools like 'glib-mkenums' visible
get_filename_component(GLIB_TOOL_DIR "${CURRENT_INSTALLED_DIR}/tools/glib" ABSOLUTE)
message(STATUS "Using glib tools: ${GLIB_TOOL_DIR}")
vcpkg_add_to_path(PREPEND ${GLIB_TOOL_DIR})

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

# gst-build's meson configuration needs git. Make the tool visible.
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path("${GIT_DIR}")

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PLATFORM_OPTIONS
        -Dgst-full-version-script=data/misc/gstreamer-full-default.map
        # We can use EGL in Windows if port 'angle' is already installed.
        # In the case, GL API should be 'gles2'.
        -Dgst-plugins-base:gl_platform=auto # -Dgst-plugins-base:gl_platform=egl
        -Dgst-plugins-base:gl_api=opengl    # -Dgst-plugins-base:gl_api=gles2
        # use 'winrt' if system version is high enough?
        -Dgst-plugins-base:gl_winsys=win32 
    )
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_OPTIONS
        -Dgst-full-version-script= # this empty string intended
        -Dgst-plugins-base:gl_platform=cgl
        -Dgst-plugins-base:gl_winsys=cocoa
    ) 
elseif(VCPKG_TARGET_IS_ANDROID)
    list(APPEND PLATFORM_OPTIONS
        -Dgst-plugins-base:gl_platform=egl
        -Dgst-plugins-base:gl_winsys=android
    ) 
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${PLATFORM_OPTIONS}
        # gstreamer/meson_options.txt
        -Dtests=disabled
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dnls=disabled
        -Ddoc=disabled
        -Dorc=disabled
        -Dges=disabled
        # subprojects
        -Drtsp_server=disabled
        -Ddevtools=disabled
        # gst-plugins-base
        -Dgst-plugins-base:package-origin="vcpkg"
        -Dgst-plugins-base:examples=disabled
        -Dgst-plugins-base:tests=disabled
        -Dgst-plugins-base:tools=disabled
        -Dgst-plugins-base:introspection=disabled
        -Dgst-plugins-base:nls=disabled
        -Dgst-plugins-base:orc=disabled
        -Dgst-plugins-base:pango=disabled
        -Dgst-plugins-base:doc=disabled
        # gst-plugins-good
        -Dgst-plugins-good:package-origin="vcpkg"
        -Dgst-plugins-good:qt5=disabled
        -Dgst-plugins-good:soup=disabled
        -Dgst-plugins-good:lame=enabled # mp3lame
        -Dgst-plugins-good:cairo=auto # cairo[gobject]
        -Dgst-plugins-good:speex=auto # speex
        -Dgst-plugins-good:taglib=auto # taglib
        -Dgst-plugins-good:vpx=auto # libvpx
        -Dgst-plugins-good:examples=disabled
        -Dgst-plugins-good:tests=disabled
        -Dgst-plugins-good:nls=disabled
        -Dgst-plugins-good:orc=disabled
        # gst-plugins-bad
        -Dbad=${PLUGIN_BAD_SUPPORT}
        -Dgst-plugins-bad:package-origin="vcpkg"
        -Dgst-plugins-bad:opencv=disabled
        -Dgst-plugins-bad:hls-crypto=openssl
        -Dgst-plugins-bad:examples=disabled
        -Dgst-plugins-bad:tests=disabled
        -Dgst-plugins-bad:introspection=disabled
        -Dgst-plugins-bad:nls=disabled
        -Dgst-plugins-bad:orc=disabled
        # gst-plugins-ugly
        -Dugly=${PLUGIN_UGLY_SUPPORT}
        -Dgst-plugins-ugly:package-origin="vcpkg"
        -Dgst-plugins-ugly:tests=disabled
        -Dgst-plugins-ugly:nls=disabled
        -Dgst-plugins-ugly:orc=disabled
    OPTIONS_RELEASE
        -Dgst-plugins-base:glib-asserts=disabled
        -Dgst-plugins-base:glib-checks=disabled
)
if(VCPKG_TARGET_IS_WINDOWS)
    # note: can't find where z.lib comes from. replace it to appropriate library name manually
    get_filename_component(BUILD_NINJA_DBG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build.ninja" ABSOLUTE)
    vcpkg_replace_string(${BUILD_NINJA_DBG} "z.lib" "zlibd.lib")
    get_filename_component(BUILD_NINJA_REL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja" ABSOLUTE)
    vcpkg_replace_string(${BUILD_NINJA_REL} "z.lib" "zlib.lib")
    vcpkg_replace_string(${BUILD_NINJA_REL} "\"-Wno-unused\"" "") # todo: may need a patch for `gst_debug=false`
endif()

vcpkg_install_meson()
vcpkg_copy_tools(TOOL_NAMES gst-inspect-1.0 gst-launch-1.0 gst-stats-1.0 gst-typefind-1.0 AUTO_CLEAN)
vcpkg_copy_pdbs()

set(pkg_name "gstreamer-1.0")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/include/gst/gl/gstglconfig.h"
            "${CURRENT_PACKAGES_DIR}/include/${pkg_name}/gst/gl/gstglconfig.h"
)

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KHR"
                    "${CURRENT_PACKAGES_DIR}/include/GL"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/libexec"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/${pkg_name}/include"
                    "${CURRENT_PACKAGES_DIR}/libexec"
                    "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/include"
)
vcpkg_copy_pdbs()

# For pkgconfig
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB_RECURSE GST_EXT_PKGS "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/pkgconfig/*.pc")
    if (GST_EXT_PKGS)
        foreach(GST_EXT_PKG IN LISTS GST_EXT_PKGS)
            file(READ "${GST_EXT_PKG}" GST_EXT_PKG_CONTENT)
            string(REPLACE [[libdir=${prefix}/lib]] [[libdir=${prefix}/lib/gstreamer-1.0]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            string(REPLACE [[flac >= 1.1.4]] [[flac]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            file(WRITE "${GST_EXT_PKG}" "${GST_EXT_PKG_CONTENT}")
            file(COPY "${GST_EXT_PKG}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        endforeach()
    endif()
endif()
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB_RECURSE GST_EXT_PKGS "${CURRENT_PACKAGES_DIR}/debug/lib/${pkg_name}/pkgconfig/*.pc")
    if (GST_EXT_PKGS)
        foreach(GST_EXT_PKG IN LISTS GST_EXT_PKGS)
            file(READ "${GST_EXT_PKG}" GST_EXT_PKG_CONTENT)
            string(REPLACE [[libdir=${prefix}/lib]] [[libdir=${prefix}/lib/gstreamer-1.0]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            string(REPLACE [[flac >= 1.1.4]] [[flac]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            file(WRITE "${GST_EXT_PKG}" "${GST_EXT_PKG_CONTENT}")
            file(COPY "${GST_EXT_PKG}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
        endforeach()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${pkg_name}/pkgconfig"
                    "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/pkgconfig"
)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin"
                        "${CURRENT_PACKAGES_DIR}/bin"
    )
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/${pkg_name}/*.dll"
                       "${CURRENT_PACKAGES_DIR}/debug/lib/${pkg_name}/*.pdb"
    )
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/*.dll"
                       "${CURRENT_PACKAGES_DIR}/lib/${pkg_name}/*.pdb"
    )
    file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/${pkg_name}")
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/${pkg_name}")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
endif()

file(INSTALL ${GST_SOURCE_PATH}/LICENSE DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
