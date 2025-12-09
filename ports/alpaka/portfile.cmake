vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alpaka-group/alpaka
    REF ${VERSION}
    SHA512 b7b21aee985ab37e2130027b789fc4769ebe48073330bbe8c95c2125b7640c39d5ab2fa646a10ce7ea5cbe15d7ab0e3aa4b3fa3e4a8e3f17e00a5b1fcb027023
    HEAD_REF develop
)
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/alpaka")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
