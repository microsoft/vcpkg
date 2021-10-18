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

vcpkg_copy_pdbs()

# For pkgconfig
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB_RECURSE GST_EXT_PKGS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/*.pc")
    if (GST_EXT_PKGS)
        foreach(GST_EXT_PKG IN LISTS GST_EXT_PKGS)
            file(READ "${GST_EXT_PKG}" GST_EXT_PKG_CONTENT)
            string(REPLACE [[libdir=${prefix}/lib]] [[libdir=${prefix}/lib/gstreamer-1.0]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            file(WRITE "${GST_EXT_PKG}" "${GST_EXT_PKG_CONTENT}")
            file(COPY "${GST_EXT_PKG}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
        endforeach()
    endif()
endif()

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB_RECURSE GST_EXT_PKGS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/*.pc")
    if (GST_EXT_PKGS)
        foreach(GST_EXT_PKG IN LISTS GST_EXT_PKGS)
            file(READ "${GST_EXT_PKG}" GST_EXT_PKG_CONTENT)
            string(REPLACE [[libdir=${prefix}/lib]] [[libdir=${prefix}/lib/gstreamer-1.0]] GST_EXT_PKG_CONTENT "${GST_EXT_PKG_CONTENT}")
            file(WRITE "${GST_EXT_PKG}" "${GST_EXT_PKG_CONTENT}")
            file(COPY "${GST_EXT_PKG}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
        endforeach()
    endif()
endif()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB DBG_BINS "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.dll"
                       "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${DBG_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(GLOB REL_BINS "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.dll"
                       "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/*.pdb"
    )
    file(COPY ${REL_BINS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE ${DBG_BINS} ${REL_BINS})
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
