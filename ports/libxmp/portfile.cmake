vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libxmp/libxmp
    REF libxmp-${VERSION}
    SHA512 d38106075419a2931fcf83d8b81cc799e850f0a81fc4e327e940c39d50c621686580c88986e962111c706175ec9b6188dac3c53a507f020c3d6a9b4dc5fe492f
    PATCHES
        fix-cmake-config-dir.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        depackers  LIBXMP_DISABLE_DEPACKERS
        prowizard  LIBXMP_DISABLE_PROWIZARD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        -DLIBXMP_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libxmp"
    CONFIG_PATH "lib/cmake/libxmp"
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS
    AND EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libxmp.pc"
    AND EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libxmp-static.lib")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libxmp.pc" " -lxmp" " -lxmp-static")
endif()
if(VCPKG_TARGET_IS_WINDOWS
    AND EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxmp.pc"
    AND EXISTS "${CURRENT_PACKAGES_DIR}/lib/libxmp-static.lib")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxmp.pc" " -lxmp" " -lxmp-static")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/xmp.h" "defined(LIBXMP_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/COPYING" "${SOURCE_PATH}/docs/CREDITS")
