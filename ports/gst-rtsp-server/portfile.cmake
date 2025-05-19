vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF "${VERSION}"
    SHA512 60ca414d05e219b760c6b22c693a5d127b368736a160217919719ad99d7e0ec7bc7a10390edeb27cc65fc647fd41e4bd9edddb60cb429f81e267c6e78a229c60
    HEAD_REF main
)

set(SOURCE_PATH "${SOURCE_PATH}/subprojects/gst-rtsp-server")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dexamples=disabled
        -Dtests=disabled
        -Dintrospection=disabled
        -Dpackage-origin="vcpkg"
        -Ddoc=disabled
    OPTIONS_RELEASE
        -Dglib_debug=disabled
        -Dglib_assert=false
        -Dglib_checks=false
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Move plugin pkg-config files
    file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(GLOB pc_files_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files_dbg} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/"
                        "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(NOT VCPKG_BUILD_TYPE)
        file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
                           "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb"
        )
        file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer")
    endif()
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
                       "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/gstreamer")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0" "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0")
    endif()
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
