# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unterumarmung/fixed_string
    REF v0.1.1
    SHA512 8367f7cf898dd88918913f6e788cc5841eab7cd56d61f3ea21636bf3253f450d5dd6207a259d4c5980d863c2ce55fba35e3e8944341f56dbfd56faa29c39746e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFIXED_STRING_OPT_BUILD_EXAMPLES=OFF
        -DFIXED_STRING_OPT_BUILD_TESTS=OFF
        -DFIXED_STRING_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME fixed_string CONFIG_PATH lib/cmake/fixed_string)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
