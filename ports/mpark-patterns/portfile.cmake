vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpark/patterns 
    REF b3270e0dd7b6312f7a4fe8647e2333dbb86e355e
    SHA512 ca8062b92cf0d5874aba7067615ff8cb089c22cb921d6131762a8dcb2f50d4f47d80c59b62b1c9b7e70dae2dfb68a44c2a4feeb78ab5e5473e0fbdd089538314
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) #header-only library

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME mpark_patterns CONFIG_PATH "lib/cmake/mpark_patterns")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
