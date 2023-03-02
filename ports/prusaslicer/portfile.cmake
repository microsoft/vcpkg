vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO prusa3d/PrusaSlicer
    REF version_${VERSION}
    SHA512 f2ead4e26fa7f9e3e9aea11056de26cd4d30e354abbcc2af0811b68e2cc36fb57715abc5e73ff3c613f5d7e639c6bbaea72670bdffd6273282d5b99f260a47f4
    HEAD_REF master
    PATCHES
      9728.diff
      9901.diff
      fixing-build.patch
      devendor_p1.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SLIC3R_STATIC)

file(REMOVE "${SOURCE_PATH}/cmake/modules/FindEXPAT.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindOpenVDB.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/boost")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/eigen")
#file(REMOVE_RECURSE "${SOURCE_PATH}/src/imgui") # too many api changes
file(REMOVE_RECURSE "${SOURCE_PATH}/src/hidapi")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/libigl")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSLIC3R_STATIC=${SLIC3R_STATIC}
      -DSLIC3R_GUI=ON
      -DSLIC3R_WX_STABLE=OFF
      -DSLIC3R_MSVC_COMPILE_PARALLEL=OFF
      -DSLIC3R_MSVC_PDB=OFF
      -DSLIC3R_GTK=3
      -DSLIC3R_BUILD_TESTS=OFF
      -DSLIC3R_DESKTOP_INTEGRATION=ON
)


# option(SLIC3R_STATIC 			"Compile PrusaSlicer with static libraries (Boost, TBB, glew)" ${SLIC3R_STATIC_INITIAL})
# option(SLIC3R_GUI    			"Compile PrusaSlicer with GUI components (OpenGL, wxWidgets)" 1)
# option(SLIC3R_FHS               "Assume PrusaSlicer is to be installed in a FHS directory structure" 0)
# option(SLIC3R_WX_STABLE         "Build against wxWidgets stable (3.0) as oppsed to dev (3.1) on Linux" 0)
# option(SLIC3R_PCH               "Use precompiled headers" 1)
# option(SLIC3R_MSVC_COMPILE_PARALLEL "Compile on Visual Studio in parallel" 1)
# option(SLIC3R_MSVC_PDB          "Generate PDB files on MSVC in Release mode" 1)
# option(SLIC3R_PERL_XS           "Compile XS Perl module and enable Perl unit and integration tests" 0)
# option(SLIC3R_ASAN              "Enable ASan on Clang and GCC" 0)
# option(SLIC3R_UBSAN             "Enable UBSan on Clang and GCC" 0)
# option(SLIC3R_ENABLE_FORMAT_STEP "Enable compilation of STEP file support" 1)

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup()
#vcpkg_fixup_pkgconfig()

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
#file(INSTALL "${SOURCE_PATH}/COPYING.README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)