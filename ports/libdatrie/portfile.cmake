vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlwg/libdatrie
    REF "v${VERSION}"
    SHA512 293c04a80d767b7fc7762f5ec1d8b7dd9bfff8bce2267120de320c5c06bbc7e371dc3385f3f7f4a505ddf159bcfc58d1b721a9d662f1012e1d5e4f73e1e976a7
    HEAD_REF master
    PATCHES
        fix-exports.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
       tool     SKIP_TOOL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${VERSION}
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_TOOL=ON
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(NOT SKIP_TOOL)
    vcpkg_copy_tools(TOOL_NAMES trietool AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
