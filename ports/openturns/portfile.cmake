vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openturns/openturns
    REF "v${VERSION}"
    SHA512 97b79d215b0ec3c6042a2a5a3d819551ae4c8562f320af5c42175d972bc9d063059178d2ad9132aee1f05491c0190bf43e20f9e2b378793eed60de998ec06273
    HEAD_REF master
    PATCHES
      link_mpc_gmp.patch
      fix-dep.patch
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DBUILD_PYTHON:BOOL=OFF # Requires additional python modules
      -DUSE_BOOST:BOOL=ON # Required to make the distributions cross platform
      -DUSE_DOXYGEN:BOOL=OFF
      -DUSE_OPENMP:BOOL=OFF
      -DCMAKE_REQUIRE_FIND_PACKAGE_Spectra:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Eigen3:BOOL=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_primesieve:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_BISON:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_FLEX:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_TBB:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_muParser:BOOL=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_HMAT:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_LibXml2:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_HDF5:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_MPFR:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_MPC:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_NLopt:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_dlib:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Ceres:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_CMinpack:BOOL=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_Bonmin:BOOL=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_Ipopt:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Pagmo:BOOL=ON
      -D_HAVE_FR_LOC_RUNS=1
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib/cmake/" "/share/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib" "$<$<CONFIG:DEBUG>:/debug>/lib")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/openturns/OTdebug.h" "#ifndef OT_STATIC" "#if 0")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/openturns/OTdebug.h" "#ifndef OT_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/pthread.h"
            "${CURRENT_PACKAGES_DIR}/include/semaphore.h"
            "${CURRENT_PACKAGES_DIR}/include/unistd.h")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
