vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freetds/freetds
    REF v1.3.10
    HEAD_REF master
    SHA512 78b494c04e3436bfdc4997e6f0196baef27246bb7ad825c487a16f247d13c99324a39d52bfe8f5306164ae3f5c7eb43ca83944b24a3ce6b4bcd733849b4064ad
    PATCHES
        disable-tests.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
        tools WITH_TOOLS
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_PATH}")

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

set(_WCHAR_SUPPORT ON)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(_WCHAR_SUPPORT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_ODBC_WIDE=${_WCHAR_SUPPORT}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES bsqldb bsqlodbc datacopy defncopy freebcp tdspool tsql AUTO_CLEAN)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/etc")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/etc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/etc")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc" "${CURRENT_PACKAGES_DIR}/debug/etc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
