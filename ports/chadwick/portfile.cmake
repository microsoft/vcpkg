vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chadwickbureau/chadwick
    REF "v${VERSION}"
    SHA512 c0d96d86646d3e1f679debb6dc8c20f8ed52c20818cf4df299b16df62643c03b23a1ba1cb1aa54f0d5a9746a50f4183e86d0646acfe84bfcd1a227b89cca1670
    HEAD_REF master
)

set(OPTIONS "CFLAGS=\$CFLAGS -fgnu89-inline")
set(MAKE_OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MAKE_OPTIONS "AM_LDFLAGS=-no-undefined")
endif()
if(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS "LDFLAGS=\$LDFLAGS -Wl,-headerpad_max_install_names")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_make(OPTIONS ${MAKE_OPTIONS})

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
