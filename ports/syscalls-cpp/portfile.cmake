vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sapdragon/syscalls-cpp
    REF "v${VERSION}"             
    SHA512 d030794c786cb4c83121cdeb27beb5beda4c89c3cf0b9eff56ba7e38af0f5249b67fc5225eed93c6adcec37cb25f9b15c76cc17338a63537d3340542188df9c9
    HEAD_REF main                
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME syscalls-cpp)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")