if(VCPKG_TARGET_IS_LINUX AND VCPKG_HOST_IS_LINUX)
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

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO DPDK/dpdk
  REF "v${VERSION}"
  SHA512 0d0ee4eb70e8021882a1d6548cf757972388c0a561ee71bb0e4b330be61f1463f4eaec55202d7a35eef8b392ecf0b3888713692ba8cd88f850e7b9072504733e
  HEAD_REF main
  PATCHES
      0001-enable-either-static-or-shared-build.patch
      0002-fix-dependencies.patch
      0003-remove-examples-src-from-datadir.patch
      0004-stop-building-apps.patch
      0005-no-absolute-driver-path.patch
      rename-sched.h.diff
)

macro(append_bool_option feature_name option_name)
  if("${feature_name}" IN_LIST FEATURES)
    list(APPEND DPDK_OPTIONS -D${option_name}=true)
  else()
    list(APPEND DPDK_OPTIONS -D${option_name}=false)
  endif()
endmacro()

set(DPDK_OPTIONS "")
set(DPDK_OPTIONS_RELEASE "")
append_bool_option("docs" "enable_docs")
append_bool_option("kmods" "enable_kmods")
append_bool_option("tests" "tests")
append_bool_option("trace" "enable_trace_fp")

set(PYTHON_PACKAGES "")
if(VCPKG_TARGET_IS_WINDOWS)
  # https://doc.dpdk.org/guides/windows_gsg/build_dpdk.html#option-3-native-build-on-windows-using-msvc
  list(APPEND DPDK_OPTIONS "-Denable_stdatomic=true")
else()
  list(APPEND PYTHON_PACKAGES pyelftools)
endif()
if("docs" IN_LIST FEATURES)
  list(APPEND DPDK_OPTIONS_RELEASE "-Denable_docs=true")
  vcpkg_find_acquire_program(DOXYGEN)
  list(APPEND PYTHON_PACKAGES packaging sphinx)
endif()
if(PYTHON_PACKAGES)
  x_vcpkg_get_python_packages(OUT_PYTHON_VAR PYTHON3 PYTHON_VERSION "3" PACKAGES ${PYTHON_PACKAGES})
endif()

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Ddeveloper_mode=disabled
    -Ddisable_drivers=regex/cn9k
    ${DPDK_OPTIONS}
  OPTIONS_RELEASE
    ${DPDK_OPTIONS_RELEASE}
  ADDITIONAL_BINARIES
    "doxygen = ['${DOXYGEN}']"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(GLOB scripts "${CURRENT_PACKAGES_DIR}/bin/*.py")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN LISTS scripts)
  cmake_path(GET script FILENAME filename)
  file(RENAME "${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${filename}")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${filename}")
endforeach()
vcpkg_clean_executables_in_bin(FILE_NAMES none)

if("docs" IN_LIST FEATURES)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
  file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc/dpdk" "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license/README")
