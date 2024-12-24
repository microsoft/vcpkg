vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alpaka-group/alpaka
    REF ${VERSION}
    SHA512 ef161c43cafaa4e6cfa8944855dbdafe260d97b23e9275716608301ffffc0f088a3f8bf2f01dc34c38639cf40fe4266e4f48126684ba824a6db6ef3c13fd873f
    HEAD_REF develop
)
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}")
    
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/alpaka")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
