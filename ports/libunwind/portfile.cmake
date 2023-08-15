vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/libunwind/libunwind.git"
    REF 24947191d61dda869e039e0414fe97e9f594acd5
    HEAD_REF "v1.7-stable"
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)
vcpkg_build_make(ENABLE_INSTALL)
vcpkg_fixup_pkgconfig()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)