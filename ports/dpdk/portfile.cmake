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
        "    https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html#system-software"
    )
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

set(PORT_VERSION 22.07)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO DPDK/dpdk
  REF v${PORT_VERSION}
  SHA512 86892f5f61ee8f7ccd61c47767515603683d0e7a217389490a9a5d4ac87b42557572113f4cd56425fef212eff5715095a34ed3c03a3ce6351ffdcacb850b0851
  HEAD_REF main
  PATCHES
      enable-either-static-or-shared-build.patch
      fix-dependencies.patch
      remove-examples-src-from-datadir.patch
      stop-building-apps.patch
      no-absolute-driver-path.patch
)

macro(append_bool_option feature_name option_name)
  if("${feature_name}" IN_LIST FEATURES)
    list(APPEND DPDK_OPTIONS -D${option_name}=true)
  else()
    list(APPEND DPDK_OPTIONS -D${option_name}=false)
  endif()
endmacro()

set(DPDK_OPTIONS "")
append_bool_option("docs" "enable_docs")
append_bool_option("kmods" "enable_kmods")
append_bool_option("tests" "tests")
append_bool_option("trace" "enable_trace_fp")
string(REPLACE "-Denable_docs=true" "-Denable_docs=false" DPDK_OPTIONS_DEBUG "${DPDK_OPTIONS}")

list(APPEND PYTHON_PACKAGES pyelftools)
if("docs" IN_LIST FEATURES)
  list(APPEND PYTHON_PACKAGES packaging sphinx)
endif()
x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES ${PYTHON_PACKAGES})

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Ddisable_drivers=regex/cn9k
    -Dexamples=
  OPTIONS_RELEASE
    ${DPDK_OPTIONS}
  OPTIONS_DEBUG
    ${DPDK_OPTIONS_DEBUG}
)
vcpkg_install_meson()

set(tools dpdk-devbind.py dpdk-pmdinfo.py dpdk-telemetry.py dpdk-hugepages.py)
if("tests" IN_LIST FEATURES)
  list(APPEND tools dpdk-test)
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

vcpkg_fixup_pkgconfig()

if("docs" IN_LIST FEATURES)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/dpdk")
  file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc/dpdk" "${CURRENT_PACKAGES_DIR}/share/dpdk/doc")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/license/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
