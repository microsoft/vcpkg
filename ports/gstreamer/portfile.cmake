#
# The following ports disables ...
#   - arm: graphene
#   - linux: ?
#   - uwp: glib
#
vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "linux" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gst-build
    REF 1.18.4
    SHA512 9b3927ba1a2ba1e384f2141c454978f582087795a70246709ed60875bc983a42eef54f3db7617941b8dacc20c434f81ef9931834861767d7a4dc09d42beeb900
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
if(VCPKG_TARGET_IS_OSX)
    # Darwin platform has an old version of `bison`, which can't be used for `gst-build`.
    # brew install bison + PATH configuration
    #
    # todo: check the tool version and warn if too low
    #
    if(APPLE)
        message(WARNING "The version of 'bison' is too old. Please check the https://stackoverflow.com/a/35161881 and upgrade it")
    endif()
endif()

#
# todo: check https://github.com/GStreamer/gst-plugins-good/blob/master/meson_options.txt
#
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#     FEATURES
#         # ...
# )

# 
# todo: check dependencies with vcpkg ports. 
#       ex) Qt, OpenGL, codec, sound related libraries ...
# todo: check build with existing ports
#   - qt5
#   - opengl-registry[windows]
#   - gtk
#   - cairo[gobject]
#   - graphene, glib, libiconv
#

#
# the following options break the configurations.
# check scripts/cmake/vcpkg_configure_meson.cmake
#   --wrap-mode=nodownload
#
# see https://github.com/GStreamer/gst-build
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # -Dgl-headers=disabled
        -Dgst-plugins-good:qt5=disabled
        -Dgstreamer:tools=disabled
        -Dgst-examples=disabled
        # check ${SOURCE_PATH}/meson_options.txt
        # subproject options
        -Dpython=disabled # ${PYTHON3}
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
# vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/libexec
                    ${CURRENT_PACKAGES_DIR}/libexec)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin
                        ${CURRENT_PACKAGES_DIR}/bin)
endif()
