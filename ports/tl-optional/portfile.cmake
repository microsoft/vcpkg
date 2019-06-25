include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/optional
    REF v1.0.0
    SHA512 6e5020808650ec312f5cdf4bc92be9067dc214c2e02d635511e99b325d34c360ce360cf93e67287dba4b9c0d674f3cbae96a75b83b13374fbb1291d2bb0f078a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPTIONAL_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tl-optional RENAME copyright)
