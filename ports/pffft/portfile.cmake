vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpommier/pffft
    REF "v${VERSION}"
    SHA512 074c7a60ee99acddc6e04c7653b9585c6a306b4a1f05a553191021ae1916fff31cc1291ff24fd53cc1988b26142b704f9319df636af1f99a5df0099d5157eba0
    HEAD_REF master
    PATCHES
        fix-invalid-command.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")