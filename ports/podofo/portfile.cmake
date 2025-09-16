vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO podofo/podofo
    REF "${VERSION}"
    SHA512 685c5771c58195ce8b70c76f1ef352a6740e716845988d75ca0f0f1abaa548766e22bed9608143737e5cdaef284d61c189031564e0cfe4bba8103f678667dcd1
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/3rdparty/date"
    "${SOURCE_PATH}/3rdparty/fast_float.h"
    "${SOURCE_PATH}/3rdparty/fmt"
    "${SOURCE_PATH}/3rdparty/utf8cpp"
    "${SOURCE_PATH}/3rdparty/utf8proc"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fontconfig  VCPKG_LOCK_FIND_PACKAGE_Fontconfig
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PODOFO_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPKG_CONFIG_FOUND=true # enable pc file for shared linkage
        -DPODOFO_BUILD_LIB_ONLY=1
        -DPODOFO_BUILD_STATIC=${PODOFO_BUILD_STATIC}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/podofo)

if(PODOFO_BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/podofo/auxiliary/basedefs.h" "#ifdef PODOFO_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
