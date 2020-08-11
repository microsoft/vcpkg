vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://sourceware.org/git/elfutils
    REF 839342ce705d1d614585c10f736a7e4ce35543d0 #elfutils-0.180
    PATCHES configure.ac.patch
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
