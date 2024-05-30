vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rockdaboot/libpsl
    REF "${VERSION}"
    SHA512 "d8e224b2ce5d9a6ac78700eb8975d09aef4e5af7db29539e5e339c5cd100f1272371fe45757ab5383ddbcd569bdf9d697a78932ea9fdf43ff48d3cea02f644cd"
    HEAD_REF master
)

vcpkg_download_distfile(
    PUBLIC_SUFFIX_LIST_DAT 
    URLS https://raw.githubusercontent.com/publicsuffix/list/5db9b65997e3c9230ac4353b01994c2ae9667cb9/public_suffix_list.dat
    FILENAME libpsl_public_suffix_list.dat
    SHA512 08ae73cb028ce9d57ad5ce09afd76a5b379fa18e1370f6a1d094f4242ce66b0f4bf005b05e796c287ab8074aca7f30d023e430f64d3563fa93adbb2371bda220
)
file(COPY "${PUBLIC_SUFFIX_LIST_DAT}" DESTINATION "${SOURCE_PATH}/list")
file(RENAME "${SOURCE_PATH}/list/libpsl_public_suffix_list.dat" "${SOURCE_PATH}/list/public_suffix_list.dat")

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
        -Ddocs=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES psl AUTO_CLEAN)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/psl-make-dafsa" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/psl-make-dafsa")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
