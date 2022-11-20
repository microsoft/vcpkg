vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO plplot/plplot
    REF "${VERSION} Source"
    FILENAME "plplot-${VERSION}.tar.gz"
    SHA512 54533245569b724a7ef90392cc6e9ae65873e6cbab923df0f841c8b43def5e4307690894c7681802209bd3c8df97f54285310a706428f79b3340cce3207087c8
    PATCHES
        subdirs.patch
        install-interface-include-directories.patch
        use-math-h-nan.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wxwidgets PLD_wxwidgets
        wxwidgets ENABLE_wxwidgets
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDEFAULT_NO_BINDINGS=ON
        -DENABLE_cxx=ON
        -DPL_HAVE_QHULL=OFF
        -DPLPLOT_USE_QT5=OFF
        -DPL_DOUBLE=ON
        -DENABLE_DYNDRIVERS=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        "-DDATA_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/data"
        "-DDOC_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/doc"
    OPTIONS_RELEASE
        "-DDATA_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}/data"
        "-DDOC_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}/doc"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plplot)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/Copyright"
        "${SOURCE_PATH}/COPYING.LIB"
)
