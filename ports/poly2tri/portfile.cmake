vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jhasse/poly2tri
    REF 81612cb108b54c14c695808f494f432990b279fd
    SHA512 4310ca8c2c2e62374883e942aa3c78a4c132f5c827b7082a7af60e81586dad589371e52ab08edd473454d37226bcd65c57acdb1e9ec31d49f73af32401d18c79
    HEAD_REF master
    PATCHES
        cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
