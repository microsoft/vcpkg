vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gstreamer
    REF 1.20.5
    SHA512 2a996d8ac0f70c34dbbc02c875026df6e89346f0844fbaa25475075bcb6e57c81ceb7d71e729c3259eace851e3d7222cb3fe395e375d93eb45b1262a6ede1fdb
    HEAD_REF master
)

set(SOURCE_PATH "${SOURCE_PATH}/subprojects/gst-rtsp-server")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dexamples=disabled
        -Dtests=disabled
        -Dintrospection=disabled
        -Dpackage-origin="vcpkg"
    OPTIONS_RELEASE
        -Dgobject-cast-checks=disabled
        -Dglib-asserts=disabled
        -Dglib-checks=disabled
)

vcpkg_install_meson()

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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Move plugin pkg-config files
    file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(GLOB pc_files_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/*")
    file(COPY ${pc_files_dbg} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/"
                        "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
