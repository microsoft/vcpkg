vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NGSolve/netgen
    REF 3e52c44aebe468275372589bf4fb3a140c4f4da5
    SHA512 01815293ce145850b31dcde438fb6f0bb10bc51eb372f1a8ad73be33011a520d2066d7bd73b0aae390bb199d9b01d4f8d4a353c2dfe18f4bd3ee9a11ca649441
    HEAD_REF master
    PATCHES 
      git-ver.patch
      static-exports.patch
      cmake-adjustments.patch
      vcpkg-fix-cgns-link.patch
      cgns-scoped-enum.patch
      downstream-fixes.patch
      add_filesystem.patch
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS  ${OPTIONS}
      -DUSE_PYTHON=OFF
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
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
