vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF "v${VERSION}"
    SHA512 70b90d93419e9c99c94c0825b077aa5b46dadc16831ced54b46cf0898b3102d8374e237b9a63ab8ee4b47f2db40222af15e4def7626aa3945450128885ce261d
    HEAD_REF master
    PATCHES
        0005-autotools-subdirs.patch
        ax_cxx_compile_stdcxx.patch # https://github.com/hunspell/hunspell/pull/1151
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    COMMENT "Hunspell is licensed under LGPL/GPL/MPL tri-license."
    FILE_LIST
        "${SOURCE_PATH}/license.hunspell"
        "${SOURCE_PATH}/license.myspell"
        "${SOURCE_PATH}/COPYING.MPL"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.LESSER"
)
