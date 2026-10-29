vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO njh/twolame
    REF "${VERSION}"
    SHA512 9a0d3ef430ca93b561caa7e56fe60c126135b1c36294a280fa21699402b3922a3992035f3d421f3bbe131cdc04459cc907059dfe0c2f512427f305fe3936e54d
    HEAD_REF main
    PATCHES
        patches/001-fix-tl-api-export.patch
        patches/002-disable-doc-subdir.patch
        patches/003-fix-kr-declaration.patch
        patches/004-fix-frontend-msvc.patch
        patches/005-fix-pc-in-case.patch
)

set(options "")
if("tool" IN_LIST FEATURES)
    list(APPEND options "--enable-sndfile")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        list(APPEND options "LIBS=\$LIBS -lgetopt")
    endif()
else()
    list(APPEND options "--disable-sndfile")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${options}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
