set(PLPLOT_VERSION 5.13.0)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO plplot/plplot
    REF ${PLPLOT_VERSION}%20Source
    FILENAME "plplot-${PLPLOT_VERSION}.tar.gz"
    SHA512 1d5cb5da17d4bde6d675585bff1f8dcb581719249a0b2687867e767703f8dab0870e7ea44b9549a497f4ac0141a3cabf6761c49520c0e2b26ffe581468512cbb
    PATCHES
      0001-findwxwidgets-fixes.patch
      0002-wxwidgets-dev-fixes.patch
      install-interface-include-directories.patch
      use-math-h-nan.patch
      fix_utils.patch
      fix-pkg-config.patch
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
        -DDATA_DIR=${CURRENT_PACKAGES_DIR}/share/plplot
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/debug/bin
    OPTIONS_RELEASE
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/bin
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plplot)

# Remove unnecessary tool
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/debug/bin/pltek.exe"
    "${CURRENT_PACKAGES_DIR}/bin/pltek.exe"
    "${CURRENT_PACKAGES_DIR}/debug/bin/wxPLViewer.exe"
    "${CURRENT_PACKAGES_DIR}/bin/wxPLViewer.exe"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static build: Removing the full bin directory.")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/bin"
    )
endif()

# Remove unwanted and duplicate directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/plplot/examples")

file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
