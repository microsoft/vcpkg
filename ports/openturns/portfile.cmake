vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openturns/openturns
    REF v${VERSION}
    SHA512 d73c294ce8fafb99da0769791cee09a6da76d3839489dd32227a7569c1fbbfc06c2a918d3951ea5b9d7a7efb1f30d11e04a52bb8d906e37411bc372235a9832b
    HEAD_REF master
    PATCHES
        dependencies.diff
)
file(REMOVE "${SOURCE_PATH}/lib/src/Base/Algo/kissfft.hh")
file(REMOVE "${SOURCE_PATH}/lib/src/Base/Func/openturns/exprtk.hpp")
file(REMOVE "${SOURCE_PATH}/lib/src/Base/Stat/rapidcsv.h")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
      "muparser"    USE_MUPARSER
      "tbb"         USE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DBUILD_PYTHON:BOOL=OFF # Requires additional python modules
      -DUSE_BONMIN=OFF
      -DUSE_CUBA:BOOL=OFF
      -DUSE_DOXYGEN:BOOL=OFF
      -DUSE_HMAT=OFF
      -DUSE_IPOPT=OFF
      -DUSE_OPENMP:BOOL=OFF
      -DUSE_PRIMESIEVE=OFF
      -DCMAKE_REQUIRE_FIND_PACKAGE_Spectra:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Eigen3:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_TBB:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_LibXml2:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_HDF5:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_MPC:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_NLopt:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_dlib:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Ceres:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_CMinpack:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_Pagmo:BOOL=ON
      -DCMAKE_REQUIRE_FIND_PACKAGE_nanoflann:BOOL=ON
    OPTIONS_RELEASE
      "-DOPENTURNS_CONFIG_CMAKE_PATH=${CURRENT_PACKAGES_DIR}/share/${PORT}"
    OPTIONS_DEBUG
      "-DOPENTURNS_CONFIG_CMAKE_PATH=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/openturns/OTdebug.h" "#ifndef OT_STATIC" "#if 0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
    "${SOURCE_PATH}/COPYING.cobyla"
    "${SOURCE_PATH}/COPYING.dsfmt"
    "${SOURCE_PATH}/COPYING.ev3"
    "${SOURCE_PATH}/COPYING.faddeeva"
    "${SOURCE_PATH}/COPYING.fastgl"
    "${SOURCE_PATH}/COPYING.kendall"
    "${SOURCE_PATH}/COPYING.cephes"
    "${SOURCE_PATH}/COPYING.tnc"
)
