# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/defer
    REF df60d7dd6ee197d4747c5c9defd521b15d881897
    SHA512 586fa794e8f78af739f530105afdc497011d2261c0cf1483a59956cbbdb71562559c352d2a27b5b2200bbd67f2f552db0ae04997abaf4d388317645a7eeb1e3d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "defer" CONFIG_PATH "lib/cmake/defer")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
