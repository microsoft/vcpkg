if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pjsip/pjproject
    REF "${VERSION}"
    SHA512 2f83ed32f16c27808d3b9cc8f3b364c68fe88caae9765012b385a0fea70ba8ef4dcfebe3b130156047546720351a527e17d6a1e967877d6a44a6ff3a1f695599
    PATCHES
        add-required-windows-libs.patch
)

file(MAKE_DIRECTORY "${SOURCE_PATH}/pjlib/include/pj")

include("${CMAKE_CURRENT_LIST_DIR}/feature_config.cmake")

configure_pjproject_features()

print_pjproject_configuration()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/config_site.h.in"
    "${SOURCE_PATH}/pjlib/include/pj/config_site.h"
    @ONLY
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    include("${CMAKE_CURRENT_LIST_DIR}/windows_build.cmake")
    build_windows_msvc()
else()
    include("${CMAKE_CURRENT_LIST_DIR}/unix_build.cmake")
    build_unix()
endif()

vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")