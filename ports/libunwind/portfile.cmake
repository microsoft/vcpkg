vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "libunwind/libunwind"
    REF v1.7.2
    HEAD_REF "v1.7-stable"
    SHA512 b560f45cfa8ca3a60b41779afbcd862860c0f7af4014298c0b22eaec8b39740349c2077a940fb0d235c8f7d6a567e00c5cb0a04c251053f90c51320616784fd2
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)
vcpkg_build_make(ENABLE_INSTALL)
vcpkg_fixup_pkgconfig()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
