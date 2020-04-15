set(MICROHTTPD_VERSION 0.9.63)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    SHA512 cb99e7af84fb6d7c0fd3894a9dc0fbff14959b35347506bd3211a65bbfad36455007b9e67493e97c9d8394834408df10eeabdc7758573e6aae0ba6f5f87afe17
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}\\build_windows.sh)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
else() 
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/build.sh)
    set(BASH /bin/bash)
endif()

set(OPTIONS_DEBUG "")
set(OPTIONS_RELEASE "")

# Release build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    message(STATUS "Building Release Options: ${OPTIONS_RELEASE}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/lib${SEP}${ENV_LIB_PATH}")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc "${BUILD_SCRIPT}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" # BUILD DIR
            "${SOURCE_PATH}" # SOURCE DIR
            "${CURRENT_PACKAGES_DIR}" # PACKAGE DIR
            "${OPTIONS} ${OPTIONS_RELEASE}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
endif()

# Debug build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    message(STATUS "Building Debug Options: ${OPTIONS_DEBUG}")
    set(ENV{${LIB_PATH_VAR}} "${CURRENT_INSTALLED_DIR}/debug/lib${SEP}${ENV_LIB_PATH}")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc "${BUILD_SCRIPT}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" # BUILD DIR
            "${SOURCE_PATH}" # SOURCE DIR
            "${CURRENT_PACKAGES_DIR}/debug" # PACKAGE DIR
            "${OPTIONS} ${OPTIONS_DEBUG}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmicrohttpd RENAME copyright)
