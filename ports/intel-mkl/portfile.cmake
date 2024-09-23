# This package installs Intel MKL on Linux, macOS and Windows for x64.
# Configuration:
#   - ilp64
#   - dynamic CRT: intel_thread, static CRT: sequential

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/19150/w_onemkl_p_2023.0.0.25930_offline.exe # windows
# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/19116/m_onemkl_p_2023.0.0.25376_offline.dmg # macos
# https://registrationcenter-download.intel.com/akdlm/irc_nas/19138/l_onemkl_p_2023.0.0.25398_offline.sh # linux
set(sha "")
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  # nop
elseif(VCPKG_TARGET_IS_WINDOWS)
  set(filename w_onemkl_p_2023.0.0.25930_offline.exe)
  set(magic_number 19150)
  set(sha a3eb6b75241a2eccb73ed73035ff111172c55d3fa51f545c7542277a155df84ff72fc826621711153e683f84058e64cb549c030968f9f964531db76ca8a3ed46)
  set(package_infix "win")
elseif(VCPKG_TARGET_IS_OSX)
  set(filename m_onemkl_p_2023.0.0.25376_offline.dmg)
  set(magic_number 19116)
  set(sha 7b9b8c004054603e6830fb9b9c049d5a4cfc0990c224cb182ac5262ab9f1863775a67491413040e3349c590e2cca58edcfc704db9f3b9f9faa8b5b09022cd2af)
  set(package_infix "mac")
  set(package_libdir "lib")
  set(compiler_libdir "mac/compiler/lib")
elseif(VCPKG_TARGET_IS_LINUX)
  set(filename l_onemkl_p_2023.0.0.25398_offline.sh)
  set(magic_number 19138)
  set(sha b5f2f464675f0fd969dde2faf2e622b834eb1cc406c4a867148116f6c24ba5c709d98b678840f4a89a1778e12cde0ff70ce2ef59faeef3d3f3aa1d0329c71af1)
  set(package_infix "lin")
  set(package_libdir "lib/intel64")
  set(compiler_libdir "linux/compiler/lib/intel64_lin")
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

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(7Z)
    message(STATUS "Extracting offline installer")
    vcpkg_execute_required_process(
        COMMAND "${7Z}" x "${installer_path}" "-o${extract_0_dir}" "-y" "-bso0" "-bsp0"
        WORKING_DIRECTORY "${extract_0_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-0"
    )

    set(packages 
        "intel.oneapi.win.mkl.devel,v=2023.0.0-25930/oneapi-mkl-devel-for-installer_p_2023.0.0.25930.msi" # has the required libs. 
        "intel.oneapi.win.mkl.runtime,v=2023.0.0-25930/oneapi-mkl-for-installer_p_2023.0.0.25930.msi" # has the required DLLs
        #"intel.oneapi.win.compilers-common-runtime,v=2023.0.0-25922" # SVML
        "intel.oneapi.win.openmp,v=2023.0.0-25922/oneapi-comp-openmp-for-installer_p_2023.0.0.25922.msi" # OpenMP
        #"intel.oneapi.win.tbb.runtime,v=2021.8.0-25874" #TBB
        )

    foreach(pack IN LISTS packages)
        set(package_path "${extract_0_dir}/packages/${pack}")
        cmake_path(GET pack STEM LAST_ONLY packstem)
        cmake_path(NATIVE_PATH package_path package_path_native)
        vcpkg_execute_required_process(
            COMMAND "${LESSMSI}" x "${package_path_native}"
            WORKING_DIRECTORY "${extract_1_dir}" 
            LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
        )
        file(COPY "${extract_1_dir}/${packstem}/SourceDir/" DESTINATION "${extract_1_dir}")
        file(REMOVE_RECURSE "${extract_1_dir}/${packstem}")
    endforeach()

    set(mkl_dir "${extract_1_dir}/Intel/Compiler/12.0/mkl/2023.0.0")
    file(COPY "${mkl_dir}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    # see https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-link-line-advisor.html for linking
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(files "mkl_core_dll.lib" "mkl_${threading}_dll.lib" "mkl_intel_${interface}_dll.lib" "mkl_blas95_${interface}.lib" "mkl_lapack95_${interface}.lib") # "mkl_rt.lib" single dynamic lib with dynamic dispatch
      file(COPY "${mkl_dir}/redist/intel64/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin") # Could probably be reduced instead of copying all
      if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${mkl_dir}/redist/intel64/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
      endif()
    else()
      set(files "mkl_core.lib" "mkl_${threading}.lib" "mkl_intel_${interface}.lib" "mkl_blas95_${interface}.lib" "mkl_lapack95_${interface}.lib")
    endif()
    foreach(file IN LISTS files)
      file(COPY "${mkl_dir}/lib/intel64/${file}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/intel64") # instead of manual-link keep normal structure
      if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${mkl_dir}/lib/intel64/${file}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/intel64")
      endif()
    endforeach()
    file(COPY_FILE "${mkl_dir}/lib/pkgconfig/${main_pc_file}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}")

    set(compiler_dir "${extract_1_dir}/Intel/Compiler/12.0/compiler/2023.0.0")
    if(threading STREQUAL "intel_thread")
      file(COPY "${compiler_dir}/windows/redist/intel64_win/compiler/" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
      file(COPY "${compiler_dir}/windows/compiler/lib/intel64_win/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/intel64")
      file(COPY_FILE "${compiler_dir}/lib/pkgconfig/openmp.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc" "/windows/compiler/lib/intel64_win/" "/lib/intel64/")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc" "-I \${includedir}" "-I\"\${includedir}\"")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "openmp" "libiomp5")
      if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${compiler_dir}/windows/redist/intel64_win/compiler/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY "${compiler_dir}/windows/compiler/lib/intel64_win/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/intel64")
      endif()
    endif()
else()
    message(STATUS "Warning: This port is still a work on progress. 
   E.g. it is not correctly filtering the libraries in accordance with
   VCPKG_LIBRARY_LINKAGE. It is using the default threading (Intel OpenMP)
   which is known to segfault when used together with GNU OpenMP.
")

    message(STATUS "Extracting offline installer")
    if(VCPKG_TARGET_IS_LINUX)
      vcpkg_execute_required_process(
          COMMAND "bash" "--verbose" "--noprofile" "${installer_path}" "--extract-only" "--extract-folder" "${extract_0_dir}"
          WORKING_DIRECTORY "${extract_0_dir}"
          LOGNAME "extract-${TARGET_TRIPLET}-0"
      )
      file(RENAME "${extract_0_dir}/l_onemkl_p_2023.0.0.25398_offline/packages" "${extract_0_dir}/packages")
    elseif(VCPKG_TARGET_IS_OSX)
      find_program(HDIUTIL NAMES hdiutil REQUIRED)
      file(MAKE_DIRECTORY "${extract_0_dir}/packages")
      message(STATUS "... Don't interrupt.")
      vcpkg_execute_required_process(
          COMMAND "${CMAKE_COMMAND}" "-Ddmg_path=${installer_path}"
                                     "-Doutput_dir=${extract_0_dir}/packages"
                                     "-DHDIUTIL=${HDIUTIL}"
                                     -P "${CMAKE_CURRENT_LIST_DIR}/copy-from-dmg.cmake"
          WORKING_DIRECTORY "${extract_0_dir}"
          LOGNAME "extract-${TARGET_TRIPLET}-0"
      )
      message(STATUS "... Done.")
    endif()

    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.runtime,v=2023.0.0-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/mkl/2023.0.0/lib"
            "_installdir/mkl/2023.0.0/licensing"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )
    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.devel,v=2023.0.0-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/mkl/2023.0.0/bin"
            "_installdir/mkl/2023.0.0/include"
            "_installdir/mkl/2023.0.0/lib"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )
    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.openmp,v=2023.0.0-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/compiler/2023.0.0"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )

    set(mkl_dir "${extract_1_dir}/_installdir/mkl/2023.0.0")
    file(COPY "${mkl_dir}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(COPY "${mkl_dir}/${package_libdir}/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/intel64")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(to_remove_suffix .a)
    elseif(VCPKG_TARGET_IS_OSX)
      set(to_remove_suffix .dylib)
    else()
      set(to_remove_suffix .so)
    endif()
    file(GLOB_RECURSE files_to_remove
        "${CURRENT_PACKAGES_DIR}/lib/intel64/*${to_remove_suffix}"
        "${CURRENT_PACKAGES_DIR}/lib/intel64/*${to_remove_suffix}.?"
    )
    file(REMOVE ${files_to_remove})
    file(COPY_FILE "${mkl_dir}/lib/pkgconfig/${main_pc_file}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "\${exec_prefix}/${package_libdir}" "\${exec_prefix}/lib/intel64" IGNORE_UNCHANGED)
  
    set(compiler_dir "${extract_1_dir}/_installdir/compiler/2023.0.0")
    if(threading STREQUAL "intel_thread")
      file(COPY "${compiler_dir}/${compiler_libdir}/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/intel64")
      file(COPY_FILE "${compiler_dir}/lib/pkgconfig/openmp.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libiomp5.pc" "/${compiler_libdir}/" "/lib/intel64/" IGNORE_UNCHANGED)
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "openmp" "libiomp5")
    endif()
endif()

file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${main_pc_file}" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/mkl.pc")
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(GLOB pc_files RELATIVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
    foreach(file IN LISTS pc_files)
      file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${file}" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}" "/include" "/../include")
      if(NOT VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${file}" "/lib/intel64" "/../lib/intel64")
      endif()
    endforeach()
endif()

file(COPY "${mkl_dir}/lib/cmake/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "MKL_CMAKE_PATH}/../../../" "MKL_CMAKE_PATH}/../../")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "redist/\${MKL_ARCH}" "bin")
#TODO: Hardcode settings from portfile in config.cmake
#TODO: Give lapack/blas information about the correct BLA_VENDOR depending on settings. 

file(INSTALL "${mkl_dir}/licensing" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.product,v=2023.0.0-*")
vcpkg_install_copyright(FILE_LIST "${package_path}/licenses/license.htm")

file(REMOVE_RECURSE
    "${extract_0_dir}"
    "${extract_1_dir}"
    "${CURRENT_PACKAGES_DIR}/lib/intel64/cmake"
    "${CURRENT_PACKAGES_DIR}/lib/intel64/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
