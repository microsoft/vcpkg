vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rockdaboot/libpsl
    REF "${VERSION}"
    SHA512 "d8e224b2ce5d9a6ac78700eb8975d09aef4e5af7db29539e5e339c5cd100f1272371fe45757ab5383ddbcd569bdf9d697a78932ea9fdf43ff48d3cea02f644cd"
    HEAD_REF master
)

set(list_ref 0ed17ee161ed2ae551c78f3b399ac8f2724d2154)
string(SUBSTRING "${list_ref}" 0 6 short_hash)
vcpkg_download_distfile(
    PUBLIC_SUFFIX_LIST_DAT 
    URLS https://raw.githubusercontent.com/publicsuffix/list/${list_ref}/public_suffix_list.dat
    FILENAME "libpsl-public_suffix_list-${short_hash}.dat"
    SHA512 7969c40b0600baf2786af0e6503b4282d487b6603418c41f28c3b39e9cd9320ac66c0d2e8fbfa2b794e461f26843e3479d60ec24ac5c0990fe8f0c6bfaeee69d
)

vcpkg_list(SET RUNTIME_OPTIONS)
if(libidn2 IN_LIST FEATURES)
    list(APPEND RUNTIME_OPTIONS -Druntime=libidn2)
endif()
if(libicu IN_LIST FEATURES)
    list(APPEND RUNTIME_OPTIONS -Druntime=libicu)
endif()
if(RUNTIME_OPTIONS STREQUAL "")
    message(FATAL_ERROR "At least one of libidn2 and libicu should be selected.")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${RUNTIME_OPTIONS}
        "-Dpsl_file=${PUBLIC_SUFFIX_LIST_DAT}"
        -Ddocs=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libpsl.h" "defined PSL_STATIC" "1")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/psl-make-dafsa" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/psl-make-dafsa")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/psl-make-dafsa")
vcpkg_copy_tools(TOOL_NAMES psl AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
