include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matthijs/sqlpp11-connector-postgresql
    REF v0.54
    SHA512 0d26dc80e6e7d9f13e95c6aaf9b7550aa86298010e4ddd35af6cc43eed315da78eb343034691117583140be393da7af6e7c53b4e429db37023171159d79dcb7c
    HEAD_REF master
)

# Use sqlpp11-connector-postgresql's own build process, skipping tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DENABLE_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/sqlpp-connector-postgresql")


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlpp11-connector-postgresql RENAME copyright)
