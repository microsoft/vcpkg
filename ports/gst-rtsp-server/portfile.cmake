vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstreamer/gst-rtsp-server
    REF 1.19.2
    SHA512 a227471c790ea4f399748233128558cbd43e941ad9774b99ecd88c1b521a0adfe2932212e7d854f041892a7c3bfc63a1b3ea9dd06d2f0b75b7eee38e392d8c51
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dgstreamer:examples=disabled
        -Dgstreamer:tests=disabled
        -Dpackage-origin="vcpkg"
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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
