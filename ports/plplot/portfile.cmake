vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO plplot/plplot
    REF "${VERSION}%20Source"
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
        x11       PLD_xwin
        x11       CMAKE_REQUIRE_FIND_PACKAGE_X11
    INVERTED_FEATURES
        x11       CMAKE_DISABLE_FIND_PACKAGE_X11
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDEFAULT_NO_BINDINGS=ON
        -DDEFAULT_NO_QT_DEVICES=ON
        -DENABLE_cxx=ON
        -DENABLE_DYNDRIVERS=OFF
        -DENABLE_qt=OFF
        -DENABLE_tk=OFF
        -DHAVE_SHAPELIB=OFF
        -DPL_DOUBLE=ON
        -DPL_HAVE_QHULL=OFF
        -DPLD_aqt=OFF   # needs aquaterm framework
        -DPLD_pdf=OFF   # needs haru
        -DPLD_psttf=OFF # needs lasi (in addition to pango)
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Freetype=ON
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
