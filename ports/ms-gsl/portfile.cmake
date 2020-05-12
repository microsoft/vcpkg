#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 1999b48a519196711f0d03af3b7eedd49fcc6db3
    SHA512 4daa5cefdd910391c97428c6de4d7f93a8e112c59f296a9dec448ff409dae0d94f99b1389897f4ec34598dd33f82c21eb47463a394f5ea8a8c00a9cca366a1ea
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_TEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/cmake/Microsoft.GSL
    TARGET_PATH share/Microsoft.GSL
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
