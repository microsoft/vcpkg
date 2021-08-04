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

set(BUILD_with_wxwidgets OFF)
if("wxwidgets" IN_LIST FEATURES)
  set(BUILD_with_wxwidgets ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_tcl=OFF
        -DENABLE_d=OFF
        -DENABLE_qt=OFF
        -DENABLE_ocaml=OFF
        -DPL_HAVE_QHULL=OFF
        -DPLPLOT_USE_QT5=OFF
        -DPL_DOUBLE=ON
        -DPLD_wxwidgets=${BUILD_with_wxwidgets}
        -DENABLE_DYNDRIVERS=OFF
        -DDATA_DIR=${CURRENT_PACKAGES_DIR}/share/plplot
    OPTIONS_DEBUG
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/debug/bin
    OPTIONS_RELEASE
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/bin
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/plplot)

# Remove unnecessary tool
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/pltek.exe
    ${CURRENT_PACKAGES_DIR}/bin/pltek.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/wxPLViewer.exe
    ${CURRENT_PACKAGES_DIR}/bin/wxPLViewer.exe
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static build: Removing the full bin directory.")
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/bin
    )
endif()

# Remove unwanted and duplicate directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
