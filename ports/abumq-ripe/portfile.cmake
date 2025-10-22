vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abumq/ripe
    REF v${VERSION}
    SHA512 d89c80349eb7a245f825755b703401a412f934390c869607cfcaa02907f375e410d6ad2220255de475e215e7fea9a17c3fba61423e2632c1be7a40cadb69ad86
    HEAD_REF master
    PATCHES
        devendoring.patch
        cmake-config-exports.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-ripe-config.cmake"
     DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtest=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-ripe")

vcpkg_copy_tools(TOOL_NAMES ripe AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
