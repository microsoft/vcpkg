vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF "v${VERSION}_libuv_v1.48"
    SHA512 dbf03c63b0693263b77b405e8f6bf4c207795be9bd024bbc06484e523b55257add1eab632067a956d03399d91ee389c46312603e7754b152c4caf51b40f6bec4
    PATCHES
        fix-find-libuv.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_UVW_LIBS=ON
        -DBUILD_UVW_SHARED_LIB=OFF
        -DFETCH_LIBUV=OFF
        -DFIND_LIBUV=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uvw)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/uvw/config.h" "#ifndef UVW_AS_LIB" "#define UVW_AS_LIB\n#ifndef UVW_AS_LIB")

file(READ "${CURRENT_PACKAGES_DIR}/share/uvw/uvwConfig.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/uvw/uvwConfig.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(libuv)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
