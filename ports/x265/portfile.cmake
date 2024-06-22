vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO multicoreware/x265_git
    REF "${VERSION}"
    SHA512 cfc3fdd7ce10a6cadf4515707d8f338fe58329cbbbcac11a85f00376e29156baccfb19a514ac2bc816432d15a2a4eb1bb7e16e3a870b6b9f9bc28e1a44270091
    HEAD_REF master
    PATCHES
        disable-install-pdb.patch
        version.patch
        linkage.diff
        pkgconfig.diff
        pthread.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        tool   ENABLE_CLI
)

set(ASSEMBLY_OPTIONS "-DENABLE_ASSEMBLY=OFF")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    set(ASSEMBLY_OPTIONS "-DENABLE_ASSEMBLY=ON" "-DNASM_EXECUTABLE=${NASM}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/source"
    OPTIONS
        ${OPTIONS}
        ${ASSEMBLY_OPTIONS}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_LIBNUMA=OFF
        "-DVERSION=${VERSION}"
    OPTIONS_DEBUG
        -DENABLE_CLI=OFF
    MAYBE_UNUSED_VARIABLES
        ENABLE_LIBNUMA
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES x265 AUTO_CLEAN)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/x265.h" "#ifdef X265_API_IMPORTS" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
