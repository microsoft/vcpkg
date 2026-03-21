set(EXTRA_PATCH)
if("high-performance" IN_LIST FEATURES)
   set(EXTRA_PATCH "fix-precision.patch")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO coin3d/dime
  REF 8cec48a1c27475f040f08a504ca0c59bd88a9d5b
  SHA512 bffe8a994aac87b697ec000d6e162a505368e0bd3d1031ce17319ad20ec042f4c96b81283c6fa1092e3a53196d576db4a5b1e8d670d8ec9eb82681b71614724e
  PATCHES
    fix-cmake.patch
    fix-clang.patch
    fix-tools.patch
    fix-windows-debug-output.patch
    ${EXTRA_PATCH}
)

set(BUILD_SHARED_LIBS OFF)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
   set(BUILD_SHARED_LIBS ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
  tools  DIME_BUILD_TOOLS
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DDIME_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    -DDIME_BUILD_DOCUMENTATION=OFF
    -DDIME_BUILD_AWESOME_DOCUMENTATION=OFF
    -DDIME_BUILD_INTERNAL_DOCUMENTATION=OFF
    -DDIME_BUILD_DOCUMENTATION_MAN=OFF
    -DDIME_BUILD_DOCUMENTATION_QTHELP=OFF
    -DDIME_BUILD_DOCUMENTATION_CHM=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if("tools" IN_LIST FEATURES)
   vcpkg_copy_tools(TOOL_NAMES dxf2vrml dxfsphere AUTO_CLEAN)
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
