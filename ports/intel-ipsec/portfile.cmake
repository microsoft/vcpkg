vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/intel-ipsec-mb
    REF "v${VERSION}"
    SHA512 1fca0797d73fc2edbd9edecfc5628c4926512dc414a6fa832602d3d7abd6d86b1305013d1b433a21b77f4bc2b215d5f947553791925f2698fb30f90f9e7086ef
    HEAD_REF master
    PATCHES
        fix-dll-install.patch
        build-only-lib.patch
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_DIR "${NASM}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NASM_DIR}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(DEBUG_LIB "${CURRENT_PACKAGES_DIR}/debug/intel-ipsec-mb")
set(RELEASE_LIB "${CURRENT_PACKAGES_DIR}/intel-ipsec-mb")

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
        file(INSTALL "${DEBUG_LIB}/libIPSec_MB.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(INTEL_IPSEC_CONFIGURATION "DEBUG")
        if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
            set(INTEL_IPSEC_LOCATION "debug/lib/libIPSec_MB.lib")
            configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-debug.cmake" @ONLY)
        else()
            file(INSTALL "${DEBUG_LIB}/libIPSec_MB.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(INSTALL "${DEBUG_LIB}/libIPSec_MB.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(INSTALL "${DEBUG_LIB}/libIPSec_MB.exp" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            set(INTEL_IPSEC_LOCATION "debug/bin/libIPSec_MB.dll")
            set(INTEL_IPSEC_IMPLIB "debug/lib/libIPSec_MB.lib")
            configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets-implib.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-debug.cmake" @ONLY)
        endif()
    endif()

    file(INSTALL "${RELEASE_LIB}/libIPSec_MB.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    set(INTEL_IPSEC_CONFIGURATION "RELEASE")
    if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        set(INTEL_IPSEC_LOCATION "lib/libIPSec_MB.lib")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-release.cmake" @ONLY)
    else()
        file(INSTALL "${RELEASE_LIB}/libIPSec_MB.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${RELEASE_LIB}/libIPSec_MB.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${RELEASE_LIB}/libIPSec_MB.exp" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        set(INTEL_IPSEC_LOCATION "bin/libIPSec_MB.dll")
        set(INTEL_IPSEC_IMPLIB "lib/libIPSec_MB.lib")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets-implib.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-release.cmake" @ONLY)
    endif()
else()
    if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
        set(LIB_SUFFIX ".a")
    else()
        set(LIB_SUFFIX ".so")
    endif()

    if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
        set(INTEL_IPSEC_CONFIGURATION "DEBUG")
        file(INSTALL "${DEBUG_LIB}/libIPSec_MB${LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(INTEL_IPSEC_LOCATION "debug/lib/libIPSec_MB${LIB_SUFFIX}")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-debug.cmake" @ONLY)
    endif()

    set(INTEL_IPSEC_CONFIGURATION "RELEASE")
    
    file(INSTALL "${RELEASE_LIB}/libIPSec_MB${LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    set(INTEL_IPSEC_LOCATION "lib/libIPSec_MB${LIB_SUFFIX}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-release.cmake" @ONLY)
endif()

file(INSTALL "${RELEASE_LIB}/intel-ipsec-mb.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsecConfig.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsecConfig.cmake" @ONLY)
file(REMOVE_RECURSE "${DEBUG_LIB}" "${RELEASE_LIB}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
