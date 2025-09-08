# This package installs Intel MKL on Linux, macOS and Windows for x64.
# Configuration:
#   - ilp64
#   - dynamic CRT: intel_thread, static CRT: sequential

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/2b9cdf66-5291-418e-a7e8-f90515cc9098/w_onemkl_p_2023.2.0.49500_offline.exe # windows
# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/dd6ae4b7-5d07-4307-8163-e1ccf7a770a0/m_onemkl_p_2023.2.2.9_offline.dmg # macos
# https://registrationcenter-download.intel.com/akdlm/IRC_NAS/adb8a02c-4ee7-4882-97d6-a524150da358/l_onemkl_p_2023.2.0.49497_offline.sh # linux
set(sha "")
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  # nop
elseif(VCPKG_TARGET_IS_WINDOWS)
  set(mkl_version 2023.2.0) 
  set(version_magic_number 49496)
  set(filename w_onemkl_p_2023.2.0.49500_offline.exe)
  set(magic_number 2b9cdf66-5291-418e-a7e8-f90515cc9098)
  set(sha 00ef5e9e059290474fb0ed5eeec5b76fd2793d45e5707e90125adecfc526af8ca716bd0f33dbe9f077b56bf30c2cbdd27401978a087687600c6c7e5847767857)
  set(package_infix "win")
elseif(VCPKG_TARGET_IS_OSX)
  set(mkl_version 2023.2.2)
  set(mkl_version_openmp 2023.2.0)
  set(filename m_onemkl_p_2023.2.2.9_offline.dmg)
  set(magic_number dd6ae4b7-5d07-4307-8163-e1ccf7a770a0)
  set(sha 9de501e0c6553265a5226ff0b00bb36f5a1c89c39114c1a64a5ae816a58b50981faf341e98e00aec11103c565059567b96e61413aa09b22462c1c5ec975c5cb9)
  set(package_infix "mac")
  set(package_libdir "lib")
  set(compiler_libdir "mac/compiler/lib")
elseif(VCPKG_TARGET_IS_LINUX)
  set(mkl_version 2023.2.0)
  set(mkl_version_openmp 2023.2.0)
  set(version_magic_number 49497)
  set(filename l_onemkl_p_2023.2.0.49497_offline.sh)
  set(magic_number adb8a02c-4ee7-4882-97d6-a524150da358)
  set(sha 421d4c33014b9a77799273f78db9877c72401d7b2a9b697abb9e148def008c58259b11c0238ab658c8f8499b13ac7bb880b91d57338345e77d0475d5d65c39f3)
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
        "intel.oneapi.win.mkl.devel,v=${mkl_version}-${version_magic_number}/oneapi-mkl-devel-for-installer_p_${mkl_version}.${version_magic_number}.msi" # has the required libs. 
        "intel.oneapi.win.mkl.runtime,v=${mkl_version}-${version_magic_number}/oneapi-mkl-for-installer_p_${mkl_version}.${version_magic_number}.msi" # has the required DLLs
        #"intel.oneapi.win.compilers-common-runtime,v=${mkl_version}-25922" # SVML
        "intel.oneapi.win.openmp,v=${mkl_version}-${version_magic_number}/oneapi-comp-openmp-for-installer_p_${mkl_version}.${version_magic_number}.msi" # OpenMP
        #"intel.oneapi.win.tbb.runtime,v=${mkl_version}-25874" #TBB
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

    set(mkl_dir "${extract_1_dir}/Intel/Compiler/12.0/mkl/${mkl_version}")
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

    set(compiler_dir "${extract_1_dir}/Intel/Compiler/12.0/compiler/${mkl_version}")
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
      file(RENAME "${extract_0_dir}/l_onemkl_p_${mkl_version}.${version_magic_number}_offline/packages" "${extract_0_dir}/packages")
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

    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.runtime,v=${mkl_version}-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/mkl/${mkl_version}/lib"
            "_installdir/mkl/${mkl_version}/licensing"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )
    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.devel,v=${mkl_version}-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/mkl/${mkl_version}/bin"
            "_installdir/mkl/${mkl_version}/include"
            "_installdir/mkl/${mkl_version}/lib"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )
    file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.openmp,v=${mkl_version_openmp}-*")
    cmake_path(GET package_path STEM LAST_ONLY packstem)
    message(STATUS "Extracting ${packstem}")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "tar" "-xf" "${package_path}/cupPayload.cup"
            "_installdir/compiler/${mkl_version_openmp}"
        WORKING_DIRECTORY "${extract_1_dir}"
        LOGNAME "extract-${TARGET_TRIPLET}-${packstem}"
    )

    set(mkl_dir "${extract_1_dir}/_installdir/mkl/${mkl_version}")
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
  
    set(compiler_dir "${extract_1_dir}/_installdir/compiler/${mkl_version_openmp}")
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
if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/mkl/MKLConfig.cmake" "define_param(MKL_LINK DEFAULT_MKL_LINK MKL_LINK_LIST)" 
[[define_param(MKL_LINK DEFAULT_MKL_LINK MKL_LINK_LIST)
 set(MKL_LINK "static")
]])
endif()
#TODO: Hardcode settings from portfile in config.cmake
#TODO: Give lapack/blas information about the correct BLA_VENDOR depending on settings. 

file(INSTALL "${mkl_dir}/licensing" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(GLOB package_path "${extract_0_dir}/packages/intel.oneapi.${package_infix}.mkl.product,v=${mkl_version}-*")
vcpkg_install_copyright(FILE_LIST "${package_path}/licenses/license.htm")

file(REMOVE_RECURSE
    "${extract_0_dir}"
    "${extract_1_dir}"
    "${CURRENT_PACKAGES_DIR}/lib/intel64/cmake"
    "${CURRENT_PACKAGES_DIR}/lib/intel64/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
