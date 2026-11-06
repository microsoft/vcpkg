vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openturns/openturns
    REF v${VERSION}
    SHA512 4c6c0c5770cdec51e6aad2a463ed5e73c1d17ac234dbc3d746a70c20939de4636e62e03a559fd6a2a2454ffef3cfb4882123018bc563b3c8f468ff5f64c1b543
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
      -DBUILD_PYTHON=OFF # Requires additional python modules
      -DUSE_BONMIN=OFF
      -DUSE_CUBA=OFF
      -DUSE_HIGHS=OFF
      -DUSE_HMAT=OFF
      -DUSE_IPOPT=OFF
      -DUSE_OPENMP=OFF
      -DUSE_PRIMESIEVE=OFF
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
