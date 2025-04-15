vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF 0b146076a162ad38b3f3342dc758938f83947dd1
    SHA512 94d0631bf15e5fa5c6992f89a647b6561967f303fe1b6b2e8517e9c77336cafdf28eadfdbeadb96824a490c3774e07dd0270ccae31686680d3bd74155e4ab8c0
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libzip       OPENXLSX_ENABLE_LIBZIP
)

file(REMOVE_RECURSE "${SOURCE_PATH}/external/nowide")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPENXLSX_LIBRARY_TYPE "STATIC")
else()
    set(OPENXLSX_LIBRARY_TYPE "SHARED")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPENXLSX_CREATE_DOCS=OFF
        -DOPENXLSX_BUILD_SAMPLES=OFF
        -DOPENXLSX_BUILD_TESTS=OFF
        -DOPENXLSX_LIBRARY_TYPE="${OPENXLSX_LIBRARY_TYPE}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenXLSX)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/OpenXLSX/external/pugixml" DESTINATION "${CURRENT_PACKAGES_DIR}/include/OpenXLSX/external")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
