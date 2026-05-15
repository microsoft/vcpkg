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
)

if("tool" IN_LIST FEATURES)
    set(_sndfile_opt "--enable-sndfile")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(_getopt_libs "LIBS=-lgetopt")
    endif()
else()
    set(_sndfile_opt "--disable-sndfile")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${_sndfile_opt}
        ${_getopt_libs}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
# vcpkg_fixup_pkgconfig() does not do its job
if(NOT VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(_pc_suffix IN ITEMS "lib/pkgconfig/twolame.pc" "debug/lib/pkgconfig/twolame.pc")
        set(_pc_file "${CURRENT_PACKAGES_DIR}/${_pc_suffix}")
        if(EXISTS "${_pc_file}")
            file(READ "${_pc_file}" _pc_content)
            string(REPLACE "-ltwolame" "-ltwolame -lm" _pc_content "${_pc_content}")
            string(REGEX REPLACE "Libs\\.Private:[^\n]*" "Libs.Private:" _pc_content "${_pc_content}")
            file(WRITE "${_pc_file}" "${_pc_content}")
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
