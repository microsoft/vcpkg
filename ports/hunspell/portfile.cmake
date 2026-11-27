vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF "v${VERSION}"
    SHA512 b078c65c9ba0dd0016e1cd36e8e185c8707ec5d979177b91c93dff2ec5190f5cceb09a678580b5098cece8bf7cee4fd09ae4a3500dfe3c95a0a0345511afc433
    HEAD_REF master
)

file(REMOVE "${SOURCE_PATH}/README") #README is a symlink
configure_file("${SOURCE_PATH}/README.md" "${SOURCE_PATH}/README" COPYONLY)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -DHUNSPELL_STATIC")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DHUNSPELL_STATIC")
endif()

vcpkg_list(SET options)

if("tools" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-tools")
else()
    vcpkg_list(APPEND options "--disable-tools")
endif()

if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    ADDITIONAL_MSYS_PACKAGES gzip
    OPTIONS
        ${options}
    OPTIONS_DEBUG
        --disable-tools
)

if("nls" IN_LIST FEATURES)
    vcpkg_build_make(BUILD_TARGET dist LOGFILE_ROOT build-dist)
endif()

vcpkg_install_make()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

vcpkg_fixup_pkgconfig()

set(HUNSPELL_EXPORT_HDR "${CURRENT_PACKAGES_DIR}/include/hunspell/hunvisapi.h")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${HUNSPELL_EXPORT_HDR}" "#if defined(HUNSPELL_STATIC)" "#if 1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
	"${CURRENT_PACKAGES_DIR}/share"
)

vcpkg_install_copyright(
    COMMENT "Hunspell is licensed under LGPL/GPL/MPL tri-license."
    FILE_LIST
        "${SOURCE_PATH}/license.hunspell"
        "${SOURCE_PATH}/license.myspell"
        "${SOURCE_PATH}/COPYING.MPL"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.LESSER"
)
