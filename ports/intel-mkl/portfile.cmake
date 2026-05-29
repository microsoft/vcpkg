# This package installs Intel MKL on Linux, macOS and Windows for x64.
# Configuration:
#   - ilp64
#   - dynamic CRT: intel_thread, static CRT: sequential

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/307bccae-8631-4712-8999-02a8abf51994/intel-onemkl-2025.2.0.630_offline.exe # windows
# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/47c7d946-fca1-441a-b0df-b094e3f045ea/intel-onemkl-2025.2.0.629_offline.sh # linux
set(sha "")
set(mkl_version 2025.2.0)
set(mkl_short_version 2025.2)
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  # nop
elseif(VCPKG_TARGET_IS_WINDOWS)
  set(filename intel-onemkl-2025.2.0.630_offline.exe)
  set(magic_number 307bccae-8631-4712-8999-02a8abf51994)
  set(sha 13d6c1ab943d2a3a16ee29be995215ef14eb469215c24633d9fdff1f0e1b3e78225ed92780b9a20d90812160da5a4969e16f0e9df36df45389c4fab4b5ecac3d)
  set(package_infix "win")
  set(package_libdir "lib")
  set(runtime_dir "bin")
elseif(VCPKG_TARGET_IS_LINUX)
  set(filename intel-onemkl-2025.2.0.629_offline.sh)
  set(magic_number 47c7d946-fca1-441a-b0df-b094e3f045ea)
  set(sha 60e0b86b2e63da1becb527db0d912d19e2a664671e1e6cf54ac6fad35ced3bb791e490d4b7d1a555231a0b553a32652d1c6c41869222c88f30e17fee5c436cd3)
  set(package_infix "lin")
  set(package_libdir "lib")
  set(runtime_dir "lib")
endif()

if(NOT sha)
  message(WARNING "${PORT} is empty for ${TARGET_TRIPLET}.")
  return()
endif()

vcpkg_download_distfile(installer_path
    URLS "https://registrationcenter-download.intel.com/akdlm/IRC_NAS/${magic_number}/${filename}"
    FILENAME "${filename}"
    SHA512 "${sha}"
)

# Note: intel_thread and lp64 are the defaults.
set(interface "ilp64") # or ilp64; ilp == 64 bit int api
#https://www.intel.com/content/www/us/en/develop/documentation/onemkl-linux-developer-guide/top/linking-your-application-with-onemkl/linking-in-detail/linking-with-interface-libraries/using-the-ilp64-interface-vs-lp64-interface.html
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(threading "intel_thread") #sequential or intel_thread or tbb_thread or pgi_thread
else()
    set(threading "sequential")
endif()
if(threading STREQUAL "intel_thread")
    set(short_thread "iomp")
else()
    string(SUBSTRING "${threading}" "0" "3" short_thread)
endif()
set(main_pc_file "mkl-${VCPKG_LIBRARY_LINKAGE}-${interface}-${short_thread}.pc")

# First extraction level: packages (from offline installer)
set(extract_0_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-extract")
file(REMOVE_RECURSE "${extract_0_dir}")
file(MAKE_DIRECTORY "${extract_0_dir}")

# Second extraction level: actual files (from packages)
set(extract_1_dir "${CURRENT_PACKAGES_DIR}/intel-extract")
file(REMOVE_RECURSE "${extract_1_dir}")
file(MAKE_DIRECTORY "${extract_1_dir}")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

message(STATUS "Warning: This port is still a work on progress. 
  E.g. it is not correctly filtering the libraries in accordance with
  VCPKG_LIBRARY_LINKAGE. It is using the default threading (Intel OpenMP)
  which is known to segfault when used together with GNU OpenMP.
")
  
message(STATUS "Extracting offline installer")

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_find_acquire_program(7Z)
  vcpkg_execute_required_process(
      COMMAND "${7Z}" x "${installer_path}" "-o${extract_0_dir}" "-y" "-bso0" "-bsp0"
      WORKING_DIRECTORY "${extract_0_dir}"
      LOGNAME "extract-${TARGET_TRIPLET}-0"
  )
endif()

if(VCPKG_TARGET_IS_LINUX)
  vcpkg_execute_required_process(
      COMMAND "bash" "--verbose" "--noprofile" "${installer_path}" "--extract-only" "--extract-folder" "${extract_0_dir}"
      WORKING_DIRECTORY "${extract_0_dir}"
      LOGNAME "extract-${TARGET_TRIPLET}-0"
  )
  cmake_path(GET filename STEM LAST_ONLY filename_no_ext)
  file(RENAME "${extract_0_dir}/${filename_no_ext}/packages" "${extract_0_dir}/packages")
endif()

file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.runtime,v=${mkl_version}+*")
cmake_path(GET package_path STEM LAST_ONLY packstem)
message(STATUS "Extracting ${packstem}")
vcpkg_execute_required_process(
    COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
        "_installdir/mkl/${mkl_short_version}/${runtime_dir}"
        "_installdir/mkl/${mkl_short_version}/share/doc/mkl/licensing/"
    WORKING_DIRECTORY "${extract_1_dir}"
    LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
)
file(RENAME "${extract_1_dir}/_installdir/mkl/${mkl_short_version}/share/doc/mkl/licensing/" "${extract_1_dir}/_installdir/mkl/${mkl_short_version}/licensing/")
file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.devel,v=${mkl_version}+*")
cmake_path(GET package_path STEM LAST_ONLY packstem)
message(STATUS "Extracting ${packstem}")
vcpkg_execute_required_process(
    COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
        "_installdir/mkl/${mkl_short_version}/bin"
        "_installdir/mkl/${mkl_short_version}/include"
        "_installdir/mkl/${mkl_short_version}/lib"
    WORKING_DIRECTORY "${extract_1_dir}"
    LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
)
file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.openmp,v=${mkl_version}+*")
cmake_path(GET package_path STEM LAST_ONLY packstem)
message(STATUS "Extracting ${packstem}")
vcpkg_execute_required_process(
    COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
        "_installdir/compiler/${mkl_short_version}"
    WORKING_DIRECTORY "${extract_1_dir}"
    LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
)

set(mkl_dir "${extract_1_dir}/_installdir/mkl/${mkl_short_version}")
file(COPY "${mkl_dir}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${mkl_dir}/${package_libdir}/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  file(COPY "${mkl_dir}/${runtime_dir}/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")
endif()

file(COPY_FILE "${mkl_dir}/lib/pkgconfig/${main_pc_file}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "\${exec_prefix}/${package_libdir}" "\${exec_prefix}/lib/" IGNORE_UNCHANGED)

set(compiler_dir "${extract_1_dir}/_installdir/compiler/${mkl_short_version}")
if(threading STREQUAL "intel_thread")
  file(COPY "${compiler_dir}/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(COPY "${compiler_dir}/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")
  endif()
  file(COPY_FILE "${compiler_dir}/lib/pkgconfig/openmp.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "openmp" "libiomp5")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(to_remove_suffix .a)
else()
  if(VCPKG_TARGET_IS_WINDOWS)
    set(to_remove_suffix .dll)
  else()
    set(to_remove_suffix .so)
  endif()
endif()
file(GLOB_RECURSE files_to_remove
    "${CURRENT_PACKAGES_DIR}/bin/*${to_remove_suffix}"
    "${CURRENT_PACKAGES_DIR}/lib/*${to_remove_suffix}"
    "${CURRENT_PACKAGES_DIR}/lib/*${to_remove_suffix}.?"
)
file(REMOVE ${files_to_remove})

file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/mkl.pc")
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(GLOB pc_files RELATIVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
    foreach(file IN LISTS pc_files)
      file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${file}" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}" "/include" "/../include")
      if(NOT VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}" "/lib/" "/../lib/" IGNORE_UNCHANGED)
      endif()
    endforeach()
endif()

file(COPY "${mkl_dir}/lib/cmake/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "MKL_CMAKE_PATH}/../../../" "MKL_CMAKE_PATH}/../../")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "redist/\${MKL_ARCH}" "bin")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "set(DEFAULT_MKL_LINK dynamic)" "set(DEFAULT_MKL_LINK static)")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "set(LIB_EXT \".so\")" "set(LIB_EXT \".a\")")
endif()
#TODO: Hardcode settings from portfile in config.cmake
#TODO: Give lapack/blas information about the correct BLA_VENDOR depending on settings. 

file(INSTALL "${mkl_dir}/licensing" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.product,v=${mkl_version}+*")
vcpkg_install_copyright(FILE_LIST "${package_path}/licenses/license.htm")

file(REMOVE_RECURSE
    "${extract_0_dir}"
    "${extract_1_dir}"
    "${CURRENT_PACKAGES_DIR}/bin/compiler"
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
