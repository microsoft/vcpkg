if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KRM7/gapp
    REF "v${VERSION}"
    SHA512 16588f6feb60ebdea7fe8777f231fca78285b15a58975ea228ed6b706c6ccf46b17e3cd8bc8c2eb938222439ef28170bc25b15a527c3ac70d7eb76ce0d6665b3
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGAPP_BUILD_TESTS=OFF
        -DGAPP_USE_LTO=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gapp)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/gapp/utility/utility.hpp"
        "#if defined(_WIN32) && !defined(GAPP_BUILD_STATIC)"
        "#ifndef GAPP_BUILD_STATIC\n#define GAPP_BUILD_STATIC\n#endif\n\n#if defined(_WIN32) && !defined(GAPP_BUILD_STATIC)"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc/gapp/api"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
