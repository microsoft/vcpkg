vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/fast_double_parser
    REF "v${VERSION}"
    SHA512 14a23b9e2ddc924d66f2748134364c546c6511ad380fbf59313c1d77c14dc4b0d22367a44b423f835ff2941f8d9c511f18b97ce25eda826ddc08a8eaaf7014bd
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

# No need to configure since there are no compiled components
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME FastDouble CONFIG_PATH share/cmake/FastDouble)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # Ensure no lib folder is included

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")