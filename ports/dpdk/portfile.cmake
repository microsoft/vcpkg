if(NOT VCPKG_CMAKE_SYSTEM_NAME OR NOT (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD"))
  message(FATAL_ERROR "Intel DPDK currently only supports Linux/FreeBSD platforms")
endif()

if(VCPKG_TARGET_IS_LINUX)
  execute_process(
    COMMAND uname --kernel-release
    OUTPUT_VARIABLE KERNEL_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(KERNEL_VERSION VERSION_LESS 4.4)
    message(
      WARNING
        "  Kernel version requires >= 4.4 on Linux (current version: ${KERNEL_VERSION})\n"
        "  Building may fail or have functional defects. See\n"
        "    https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html#system-software")
  endif()

  execute_process(
    COMMAND sh -c "ldd --version | head -n1 | rev | cut -d' ' -f 1 | rev"
    OUTPUT_VARIABLE GLIBC_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(GLIBC_VERSION VERSION_LESS 2.7)
    message(
      FATAL_ERROR
        "glibc version requires >= 2.7 (for features related to cpuset)")
  endif()
endif()

set(PORT_VERSION 22.03)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO DPDK/dpdk
  REF v${PORT_VERSION}
  SHA512 ff80a9f87e71cd743ea5e62f515849bc6746fe7496a0d4b63ecf2bfe0d88da74f0e6c0257c07838c1f9ff41abd81827932b97731fb0fce60d56a8bab7e32347c
  HEAD_REF main
  PATCHES
      stop-building-apps.patch
      remove-examples-src-from-datadir.patch)

macro(append_bool_option feature_name option_name)
  if("${feature_name}" IN_LIST FEATURES)
    list(APPEND DPDK_OPTIONS -D${option_name}=true)
  else()
    list(APPEND DPDK_OPTIONS -D${option_name}=false)
  endif()
endmacro()

append_bool_option("docs" "enable_docs")
append_bool_option("kmods" "enable_kmods")
append_bool_option("tests" "tests")
append_bool_option("trace" "enable_trace_fp")

list(APPEND PYTHON_PACKAGES pyelftools)
if("docs" IN_LIST FEATURES)
  list(APPEND PYTHON_PACKAGES packaging sphinx)
endif()
x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES ${PYTHON_PACKAGES})

# Backup the environment variable PKG_CONFIG_PATH before calling
# vcpkg_configure_meson. Relevant issue:
# https://github.com/microsoft/vcpkg/pull/25118
vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
                      OPTIONS -Dexamples= ${DPDK_OPTIONS})
vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)

vcpkg_install_meson()

vcpkg_copy_tools(TOOL_NAMES dpdk-devbind.py dpdk-pmdinfo.py dpdk-telemetry.py
                 dpdk-hugepages.py AUTO_CLEAN)

vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(
  INSTALL "${SOURCE_PATH}/license/README"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" @ONLY)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}ConfigVersion.cmake"
  VERSION ${PORT_VERSION}
  COMPATIBILITY AnyNewerVersion)
