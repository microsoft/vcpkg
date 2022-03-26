vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/intel-ipsec-mb
    REF bde82c8737edc04d80549f0a68225ede7e5cefd #v1.1
    SHA512 f41dcde88b062e8ec2327987c6d36cd4f74a5e4fea386cc1ef8364f1dc432a2db02ca7d3312c0471b443cf93e815af6d74a4819c249afd6777aa91693b2546e5
    HEAD_REF master
    PATCHES
        always-generate-pdb.patch # https://github.com/intel/intel-ipsec-mb/pull/93
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_DIR "${NASM}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${NASM_DIR}")

vcpkg_list(SET MAKE_OPTIONS)
set(INTEL_IPSEC_STATIC_OR_SHARED SHARED)
if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    vcpkg_list(APPEND MAKE_OPTIONS SHARED=n)
    set(INTEL_IPSEC_STATIC_OR_SHARED STATIC)
endif()

set(DEBUG_LIB "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib")
set(RELEASE_LIB "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib")

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH lib
        PROJECT_NAME win_x64.mak
        OPTIONS ${MAKE_OPTIONS}
        OPTIONS_DEBUG DEBUG=y
    )

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

    find_program(MAKE make REQUIRED)
    if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        set(INTEL_IPSEC_CONFIGURATION "DEBUG")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        vcpkg_execute_build_process(
            COMMAND "${MAKE}" "-j${VCPKG_CONCURRENCY}" ${MAKE_OPTIONS}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
        )

        file(INSTALL "${DEBUG_LIB}/libIPSec_MB${LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(INTEL_IPSEC_LOCATION "debug/lib/libIPSec_MB${LIB_SUFFIX}")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-debug.cmake" @ONLY)
    endif()

    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    set(INTEL_IPSEC_CONFIGURATION "RELEASE")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
        COMMAND "${MAKE}" -j ${MAKE_OPTIONS}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib"
        LOGNAME "build-${TARGET_TRIPLET}-rel"
    )

    file(INSTALL "${RELEASE_LIB}/libIPSec_MB${LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    set(INTEL_IPSEC_LOCATION "lib/libIPSec_MB${LIB_SUFFIX}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsec-targets.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsec-targets-release.cmake" @ONLY)
endif()

file(INSTALL "${SOURCE_PATH}/lib/intel-ipsec-mb.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
configure_file("${CMAKE_CURRENT_LIST_DIR}/intel-ipsecConfig.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/intel-ipsecConfig.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
