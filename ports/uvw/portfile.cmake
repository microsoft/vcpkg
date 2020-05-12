#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF da3b5f00f574df447dc0ff69af280a9eadc95333 # v2.3.1_libuv-v1.34
    SHA512 a1a00838b909ef41157911851e48581b70a9a06da8507357567208d205e709f50f891246708f33683aca2aaf7fde8b36147539152727c782604442e385b4e080
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/uvw-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw)
