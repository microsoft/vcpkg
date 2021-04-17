vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp" "emscripten" "wasm32" "android" "ios")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gst-build
    REF 1.18.4
    SHA512 9b3927ba1a2ba1e384f2141c454978f582087795a70246709ed60875bc983a42eef54f3db7617941b8dacc20c434f81ef9931834861767d7a4dc09d42beeb900
    HEAD_REF master
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

#
# check scripts/cmake/vcpkg_configure_meson.cmake
#   --wrap-mode=nodownload
#
# References
#   https://github.com/GStreamer/gst-build
#   https://github.com/GStreamer/gst-plugins-good/blob/master/meson_options.txt
#
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # plugin/tool
        -Dgst-plugins-good:qt5=disabled
        -Dgstreamer:tools=disabled
        -Dgst-examples=disabled
        # see ${SOURCE_PATH}/meson_options.txt
        -Dpython=disabled
        -Dlibav=disabled
        -Dlibnice=disabled
        -Dugly=disabled
        -Dbad=disabled
        -Ddevtools=disabled
        -Dges=disabled
        -Drtsp_server=disabled
        -Domx=disabled
        -Dvaapi=disabled
        -Dsharp=disabled
        -Drs=disabled
        -Dtls=disabled
        # common options
        -Dtests=disabled
        -Dexamples=disabled
        -Dintrospection=disabled
        -Dnls=disabled
        -Dorc=disabled
        -Ddoc=disabled
        -Dgtk_doc=disabled
)
vcpkg_install_meson()

# todo: use vcpkg_copy_tool_dependencies for Windows
file(RENAME ${CURRENT_PACKAGES_DIR}/libexec ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_tools(
    TOOL_NAMES gst-device-monitor-1.0 gst-discoverer-1.0 gst-play-1.0
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/gstreamer-1.0
    AUTO_CLEAN
)

# Remove duplicated GL headers (we already have `opengl-registry`)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR
                    ${CURRENT_PACKAGES_DIR}/include/GL
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h 
            ${CURRENT_PACKAGES_DIR}/include/gstreamer-1.0/gst/gl/gstglconfig.h
)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
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
endif()
