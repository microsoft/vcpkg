vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO podofo/podofo
    REF "${VERSION}"
    SHA512 cb5608f7496974c0d546c73000d2551913e18a13319b991a7532a46dd04ee7305e0df4a1233156d0171cd965d0af1cf99a27b2400fcc6117a5d1f04c0ad8b364
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/3rdparty/date"
    "${SOURCE_PATH}/3rdparty/fastfloat"
    "${SOURCE_PATH}/3rdparty/fmtlib"
    "${SOURCE_PATH}/3rdparty/tcbspan"
    "${SOURCE_PATH}/3rdparty/tclap"
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
        -DPODOFO_DEVENDOR_DATE=1
        -DPODOFO_DEVENDOR_FASTFLOAT=1
        -DPODOFO_DEVENDOR_FMT=1
        -DPODOFO_DEVENDOR_FMT_HEADER_ONLY=1
        -DPODOFO_DEVENDOR_TCBSPAN=1
        -DPODOFO_DEVENDOR_UTF8CPP=1
        -DPODOFO_DEVENDOR_UTF8PROC=1
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LGPL" "${SOURCE_PATH}/COPYING.MPL")
