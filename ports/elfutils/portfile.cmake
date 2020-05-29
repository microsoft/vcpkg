#vcpkg_download_distfile(ARCHIVE
#    URLS "ftp://sourceware.org/pub/elfutils/0.178/elfutils-0.178.tar.bz2"
#    FILENAME "elfutils.tar.bz2"
#    SHA512 356656ad0db8f6877b461de1a11280de16a9cc5d8dde4381a938a212e828e32755135e5e3171d311c4c9297b728fbd98123048e2e8fbf7fe7de68976a2daabe5
#)
# vcpkg_extract_source_archive_ex(
    # OUT_SOURCE_PATH SOURCE_PATH
    # ARCHIVE "${ARCHIVE}"
    # PATCHES configure.ac.patch
# )

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://sourceware.org/git/elfutils
    REF 3a772880847f6a5ecf0755b752801ea02abd5a3d 
    PATCHES configure.ac.patch
    #HEAD# elfutils-0.179 	 #3a772880847f6a5ecf0755b752801ea02abd5a3d
    #SHA512 1
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    OPTIONS --disable-debuginfod 
            --with-zlib
            --with-bzlib
            --with-lzma
            --enable-maintainer-mode
)

vcpkg_install_make()
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdebuginfod.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdebuginfod.pc") #--disable-debuginfod 
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
# set(TOOL_PREFIX eu)
# set(TOOLS addr2line ar elfclassify elfcmp elfcompress elflint findtextrel make-debug-archive nm objdump ranlib readelf size stack strings strip unstrip)
# foreach(_tool ${TOOLS})
    # file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${TOOL_PREFIX}-${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${TOOL_PREFIX}-${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
# endforeach()
# file(MAKE_DIRECTORY  "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# file(RENAME "${CURRENT_PACKAGES_DIR}/share/locale" "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
