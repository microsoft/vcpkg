vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/liba52
    REF "${VERSION}"
    SHA512 85a406053410b9ccd861b94e249ad4241e150801c91536496446bdf977bac1b42025dbcb63f519a5b169330ba40e56dba85f5ce101d890dc09d33617e2b51c76
    PATCHES
        fix-dll-export.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    RENAME liba52
    PATTERN "*.in" EXCLUDE
    PATTERN "*.am" EXCLUDE
)
file(INSTALL "${SOURCE_PATH}/vc++/config.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/liba52")
file(INSTALL "${SOURCE_PATH}/vc++/inttypes.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/liba52")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
