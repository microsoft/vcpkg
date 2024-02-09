vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NGSolve/netgen
    REF v${VERSION}
    SHA512 82095c51f2486d9f2a59d8fd696e305096ef63df5c40fef1fd95a8e8c3eb3735f7be29929105e588b8c1b6d6941d1e4c05f7f09e0d1c866c1105d5c1c064f932
    HEAD_REF master
    PATCHES 
      git-ver.patch
      static-exports.patch
      cmake-adjustments.patch
      vcpkg-fix-cgns-link.patch
      cgns-scoped-enum.patch
      downstream-fixes.patch
      add_filesystem.patch
      occ-78.patch
      142.diff
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  list(APPEND OPTIONS 
    "-DNGLIB_LIBRARY_TYPE=STATIC"
    "-DNGCORE_LIBRARY_TYPE=STATIC"
    "-DNGGUI_LIBRARY_TYPE=STATIC"
  )
  string(APPEND VCPKG_C_FLAGS " -DNGSTATIC_BUILD")
  string(APPEND VCPKG_CXX_FLAGS " -DNGSTATIC_BUILD")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        python   USE_PYTHON
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS  ${OPTIONS}
      ${FEATURE_OPTIONS}
      -DUSE_JPEG=ON
      -DUSE_CGNS=ON
      -DUSE_OCC=ON
      -DUSE_MPEG=ON
      -DUSE_SPDLOG=OFF # will be vendored otherwise
      -DUSE_GUI=OFF
      -DPREFER_SYSTEM_PYBIND11=ON
      -DENABLE_UNIT_TESTS=OFF
      -DUSE_NATIVE_ARCH=OFF
      -DUSE_MPI=OFF
      -DUSE_SUPERBUILD=OFF
      -DNETGEN_VERSION_GIT=v${VERSION} # this variable is patched in via git-ver.patch
      -DNG_INSTALL_DIR_CMAKE=lib/cmake/netgen
      -DNG_INSTALL_DIR_BIN=bin
      -DNG_INSTALL_DIR_LIB=lib
      -DNG_INSTALL_DIR_RES=share
      -DNG_INSTALL_DIR_INCLUDE=include
      -DNG_INSTALL_DIR_PYTHON=${PYTHON3_SITE}
      -DSKBUILD=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/netgen)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/nglib.h" "defined(NGSTATIC_BUILD)" "1")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/nglib.h" "define NGLIB" "define NGLIB\n#define OCCGEOMETRY\n#define JPEGLIB\n#define FFMPEG\n")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/core/ngcore_api.hpp" "!defined(NGSTATIC_BUILD)" "0")
endif()

set(config_file "${CURRENT_PACKAGES_DIR}/share/netgen/NetgenConfig.cmake")
file(READ "${config_file}" contents)
string(REPLACE "${SOURCE_PATH}" "NOT-USABLE" contents "${contents}")
string(REGEX REPLACE "\\\$<\\\$<CONFIG:Release>:([^>]+)>" "\\1" contents "${contents}")
string(REPLACE "\${NETGEN_CMAKE_DIR}/../" "\${NETGEN_CMAKE_DIR}/../../" contents "${contents}")
if(NOT VCPKG_BUILD_TYPE)
  string(REPLACE "/lib" "$<$<CONFIG:DEBUG>:/debug>/lib" contents "${contents}")
endif()
string(REGEX REPLACE "$<CONFIG:Release>:([^>]+)>" "\\1" contents "${contents}")
file(WRITE "${config_file}" "${contents}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/netgen/NetgenConfig.cmake" "${SOURCE_PATH}" "NOT-USABLE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if("python" IN_LIST FEATURES)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/netgen/config.py" "CMAKE_INSTALL_PREFIX[^\n]+" "")
endif()
