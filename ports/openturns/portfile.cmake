vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openturns/openturns
    REF v${VERSION}
    SHA512 d73c294ce8fafb99da0769791cee09a6da76d3839489dd32227a7569c1fbbfc06c2a918d3951ea5b9d7a7efb1f30d11e04a52bb8d906e37411bc372235a9832b
    HEAD_REF master
    PATCHES
      fix-dep.patch
      fix-blas.patch
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
      -DBUILD_PYTHON:BOOL=OFF # Requires additional python modules
      -DUSE_BOOST:BOOL=ON # Required to make the distributions cross platform
      -DUSE_DOXYGEN:BOOL=OFF
      -DUSE_OPENMP:BOOL=OFF
      -DUSE_CUBA:BOOL=OFF
      -DCMAKE_REQUIRE_FIND_PACKAGE_Spectra:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Eigen3:BOOL=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_primesieve:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_BISON:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_FLEX:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_TBB:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_muParser:BOOL=ON
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib/cmake/" "/share/" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib" "$<$<CONFIG:DEBUG>:/debug>/lib" IGNORE_UNCHANGED)

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
