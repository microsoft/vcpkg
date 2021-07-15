vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp" "emscripten" "wasm32" "android" "ios")

vcpkg_from_github(
    OUT_SOURCE_PATH GST_BUILD_SOURCE_PATH
    REPO gstreamer/gst-build
    REF 1.18.4
    SHA512 9b3927ba1a2ba1e384f2141c454978f582087795a70246709ed60875bc983a42eef54f3db7617941b8dacc20c434f81ef9931834861767d7a4dc09d42beeb900
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.18.4
    SHA512 684a7ce93143a0c3e0ce627ab2bf1451d49735b4bab273f308bc3b48d8312f7c13c0afa7e71f3a3a7274b90373215636dd8ff0076f143cbe26061de0c4efa102
    HEAD_REF master
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PLUGIN_BASE_PATCHES plugins-base-use-zlib.patch)
    list(APPEND PLUGIN_GOOD_PATCHES plugins-good-use-zlib.patch)
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_BASE_SOURCE_PATH
    REPO gstreamer/gst-plugins-base
    REF 1.18.4
    SHA512 b89924e90f880195740421f2eec3f2a667b96f6ca92ccaf87da246e9c9fd13646bf6235376844c012414a79d38dfaea8f10d56ffec900fe0b9cb8f19e722f05e
    HEAD_REF master
    PATCHES ${PLUGIN_BASE_PATCHES}
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_GOOD_SOURCE_PATH
    REPO gstreamer/gst-plugins-good
    REF 1.18.4
    SHA512 d97f4b76b6fc089b7675a9b10cabf4c704d71d663a23f34133a2671761d98e931aa87df7158f663cd9ebb6a8febd9ab1833aef7eb8be2ef2b54fad288bd0ae66
    HEAD_REF master
    PATCHES ${PLUGIN_GOOD_PATCHES}
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_BAD_SOURCE_PATH
    REPO gstreamer/gst-plugins-bad
    REF 1.18.4
    SHA512 0bf5344fbef883dbe0908495c9a50cd3bf915c5d328cf2768532ff077a9aa4255747f417a310c16c3ea86fcb79ac6ba4bf37375ff84776985451ab47b9d9ac6e
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH GST_PLUGIN_UGLY_SOURCE_PATH
    REPO gstreamer/gst-plugins-ugly
    REF 1.18.4
    SHA512 01413155d21f654a90bcf7235b5605c244d3700632ae6c56cafbbabfb11192a09c2ab01c4662ab452eabb004b09c9ec2efa72024db8be5863054d25569034a03
    HEAD_REF master
)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH GST_MESON_PORTS_SOURCE_PATH
    REPO gstreamer/meson-ports/gl-headers
    REF 5c8c7c0d3ca1f0b783272dac0b95e09414e49bc8 # master commit. Date 2021-04-21
    SHA512 d001535e1c1b5bb515ac96c7d15b25ca51460a5af0c858df53b11c7bae87c4a494e4a1b1b9c3c41a5989001db083645dde2054b82acbbeab7f9939308b676f9c
    HEAD_REF master
)

file(RENAME ${GST_SOURCE_PATH} ${GST_BUILD_SOURCE_PATH}/subprojects/gstreamer)
file(RENAME ${GST_PLUGIN_BASE_SOURCE_PATH} ${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-base)
file(RENAME ${GST_PLUGIN_GOOD_SOURCE_PATH} ${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-good)
file(RENAME ${GST_PLUGIN_BAD_SOURCE_PATH}  ${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-bad)
file(RENAME ${GST_PLUGIN_UGLY_SOURCE_PATH} ${GST_BUILD_SOURCE_PATH}/subprojects/gst-plugins-ugly)
file(RENAME ${GST_MESON_PORTS_SOURCE_PATH} ${GST_BUILD_SOURCE_PATH}/subprojects/gl-headers)

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
get_filename_component(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib ABSOLUTE)
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
    SOURCE_PATH ${GST_BUILD_SOURCE_PATH}
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
        -Dgstreamer:gtk_doc=disabled
        -Dgstreamer:introspection=disabled
        -Dgstreamer:nls=disabled
        # gst-plugins-base
        -Dgst-plugins-base:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-base:examples=disabled
        -Dgst-plugins-base:tests=disabled
        -Dgst-plugins-base:tools=disabled
        -Dgst-plugins-base:introspection=disabled
        -Dgst-plugins-base:nls=disabled
        -Dgst-plugins-base:orc=disabled
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
        -Dgst-plugins-good:nls=disabled
        -Dgst-plugins-good:orc=disabled
        # gst-plugins-bad
        -Dbad=${PLUGIN_BAD_SUPPORT}
        -Dgst-plugins-bad:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:opencv=disabled
        -Dgst-plugins-bad:hls-crypto=openssl
        -Dgst-plugins-bad:examples=disabled
        -Dgst-plugins-bad:tests=disabled
        -Dgst-plugins-bad:introspection=disabled
        -Dgst-plugins-bad:nls=${LIBRARY_LINKAGE}
        -Dgst-plugins-bad:orc=disabled
        # gst-plugins-ugly
        -Dugly=${PLUGIN_UGLY_SUPPORT}
        -Dgst-plugins-ugly:default_library=${LIBRARY_LINKAGE}
        -Dgst-plugins-ugly:tests=disabled
        -Dgst-plugins-ugly:nls=disabled
        -Dgst-plugins-ugly:orc=disabled
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
if(VCPKG_TARGET_IS_WINDOWS)
    # note: can't find where z.lib comes from. replace it to appropriate library name manually
    get_filename_component(BUILD_NINJA_DBG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build.ninja ABSOLUTE)
    vcpkg_replace_string(${BUILD_NINJA_DBG} "z.lib" "zlibd.lib")
    get_filename_component(BUILD_NINJA_REL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja ABSOLUTE)
    vcpkg_replace_string(${BUILD_NINJA_REL} "z.lib" "zlib.lib")
    vcpkg_replace_string(${BUILD_NINJA_REL} "\"-Wno-unused\"" "") # todo: may need a patch for `gst_debug=false`
endif()
vcpkg_install_meson()

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR
                    ${CURRENT_PACKAGES_DIR}/include/GL
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h 
            ${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h
)

file(INSTALL ${GST_BUILD_SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/libexec
                    ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/include
                    ${CURRENT_PACKAGES_DIR}/libexec
                    ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin
                        ${CURRENT_PACKAGES_DIR}/bin
    )
    set(PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX})
    set(SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}
                ${CURRENT_PACKAGES_DIR}/lib/${PREFIX}gstreamer-full-1.0${SUFFIX}
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB DBG_BINS ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.dll
                       ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb
    )
    file(COPY ${DBG_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(GLOB REL_BINS ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.dll
                       ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb
    )
    file(COPY ${REL_BINS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${DBG_BINS} ${REL_BINS})
endif()