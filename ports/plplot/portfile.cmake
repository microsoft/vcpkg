include(vcpkg_common_functions)

set(PLPLOT_VERSION 5.13.0)
set(PLPLOT_HASH 1d5cb5da17d4bde6d675585bff1f8dcb581719249a0b2687867e767703f8dab0870e7ea44b9549a497f4ac0141a3cabf6761c49520c0e2b26ffe581468512cbb)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/plplot-${PLPLOT_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/plplot/files/plplot/${PLPLOT_VERSION}%20Source/plplot-${PLPLOT_VERSION}.tar.gz/download"
    FILENAME "plplot-${PLPLOT_VERSION}.tar.gz"
    SHA512 ${PLPLOT_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

set(BUILD_with_wxwidgets OFF)
if("wxwidgets" IN_LIST FEATURES)
  set(BUILD_with_wxwidgets ON)
endif()

# Patch build scripts
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/install-interface-include-directories.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_tcl=OFF
        -DPL_HAVE_QHULL=OFF
        -DENABLE_qt=OFF
        -DPLPLOT_USE_QT5=OFF
        -DENABLE_ocaml=OFF
        -DPL_DOUBLE=ON
        -DENABLE_wxwidgets=${ENABLE_wxwidgets}
        -DPLD_wxpng=${ENABLE_wxwidgets}
        -DPLD_wxwidgets=${ENABLE_wxwidgets}
        -DENABLE_DYNDRIVERS=OFF
        -DDATA_DIR=${CURRENT_PACKAGES_DIR}/share/plplot
    OPTIONS_DEBUG
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/debug/bin
    OPTIONS_RELEASE
        -DDRV_DIR=${CURRENT_PACKAGES_DIR}/bin
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/plplot)

# Remove unnecessary tool
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/pltek.exe
    ${CURRENT_PACKAGES_DIR}/bin/pltek.exe
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static build: Removing the full bin directory.")
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/bin
    )
endif()

# Remove unwanted and duplicate directories
file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/include
)

file(INSTALL
    ${SOURCE_PATH}/Copyright
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/plplot
    RENAME copyright
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/share
)
