vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 70971f441d7611ba3905b5c0d5c8bf4338602ef2
    SHA512 8ff0f06eaa59e547e4f00002d27241f99f06b398d7cd021c3b8475431d59234d0aa32fff8ce74faee3468c9fb542020326547a6d9cd7b98561b3bdd233a1e715
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/pegtl/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pegtl/LICENSE ${CURRENT_PACKAGES_DIR}/share/pegtl/copyright)
