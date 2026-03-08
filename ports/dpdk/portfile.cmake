# Some dll doesn't export any symbols.
# https://doc.dpdk.org/guides-25.07/windows_gsg/intro.html#limitations
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

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
  SHA512 21b1fd1b87797a61c3480e9b049a38ea5be2fb174b8d1d397db25a0d6c04281f1951e402276299fd605763ef6aa867f1285b2321f03214aa6122553cfb53771e
  HEAD_REF main
  PATCHES
      0001-enable-either-static-or-shared-build.patch
      0002-fix-dependencies.patch
      0003-remove-examples-src-from-datadir.patch
      0004-stop-building-apps.patch
      0005-no-absolute-driver-path.patch
      0006-rename-sched.h.patch
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

# Move dll driver to bin directory.
file(GLOB PMD_DIRS "${CURRENT_PACKAGES_DIR}/lib/dpdk/pmds-*")
foreach(PMD_DIR ${PMD_DIRS})
  get_filename_component(DIR_NAME ${PMD_DIR} NAME)
  file(GLOB DLLS "${PMD_DIR}/*.dll")
  if(DLLS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/dpdk/${DIR_NAME}")
    file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/dpdk/${DIR_NAME}")
    file(REMOVE ${DLLS})
  endif()
endforeach()
if(NOT VCPKG_BUILD_TYPE)
  file(GLOB PMD_DIRS_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/dpdk/pmds-*")
  foreach(PMD_DIR ${PMD_DIRS_DEBUG})
    get_filename_component(DIR_NAME ${PMD_DIR} NAME)
    file(GLOB DLLS "${PMD_DIR}/*.dll" "${PMD_DIR}/*.pdb")
    if(DLLS)
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/dpdk/${DIR_NAME}")
      file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/dpdk/${DIR_NAME}")
      file(REMOVE ${DLLS})
    endif()
  endforeach()
endif()

# pkg_check_modules doesn't support -l:lib syntax
# https://gitlab.kitware.com/cmake/cmake/-/issues/27452
if (VCPKG_TARGET_IS_WINDOWS)
  set(PREFIX_LIB "")
else()
  set(PREFIX_LIB "lib")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdpdk.pc" "-l:lib" "-l${PREFIX_LIB}")
if(NOT VCPKG_BUILD_TYPE)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdpdk.pc" "-l:lib" "-l${PREFIX_LIB}")
endif()
