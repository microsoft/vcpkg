set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/rres
    REF "${VERSION}"
    SHA512 ca810276b4384cab49b00a73803c5ec3d4c319a9406e7ee8b28af52659418dd876e9593498dd1b9d48877f410d172726b577c77c51e8b4c0403ce1f5eff84db7
    HEAD_REF master
    PATCHES
        fix-raylib-integration.patch
        fix-shared-library-linkage.patch
)

file(INSTALL "${SOURCE_PATH}/src/rres.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(copyright_files "${SOURCE_PATH}/LICENSE")
if("raylib" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/src/rres-raylib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    # Optional compression/encryption implementations included by rres-raylib.h
    set(raylib_external_files
        aes.c
        aes.h
        lz4.c
        lz4.h
        monocypher.c
        monocypher.h
        qoi.h
    )
    list(TRANSFORM raylib_external_files PREPEND "${SOURCE_PATH}/src/external/")

    file(INSTALL ${raylib_external_files} DESTINATION "${CURRENT_PACKAGES_DIR}/include/external")
    list(APPEND copyright_files ${raylib_external_files})
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST ${copyright_files})
