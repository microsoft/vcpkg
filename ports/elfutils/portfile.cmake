vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://sourceware.org/git/elfutils
    REF ca4a785fc3061c7d136b198e9ffe0b14cf90c2be #elfutils-0.186

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
            --enable-libdebuginfod=dummy
            --with-zlib
            --with-bzlib
            --with-lzma
            --with-zstd
            --enable-maintainer-mode
    OPTIONS_RELEASE
            ac_cv_null_dereference=no # deactivating Werror due to null dereferences since NDEBUG is passed and asserts thus disabled/removed
)

vcpkg_install_make()
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdebuginfod.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdebuginfod.pc") #--disable-debuginfod 
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc/debuginfod" "${CURRENT_PACKAGES_DIR}/etc/debuginfod")

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/locale)

# Remove files with wrong linkage
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(_lib_suffix "${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
else()
    set(_lib_suffix "${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
endif()
file(GLOB_RECURSE TO_REMOVE "${CURRENT_PACKAGES_DIR}/lib/*${_lib_suffix}" "${CURRENT_PACKAGES_DIR}/debug/lib/*${_lib_suffix}" "${CURRENT_PACKAGES_DIR}/lib/*${_lib_suffix}.*" "${CURRENT_PACKAGES_DIR}/debug/lib/*${_lib_suffix}.*")
file(REMOVE ${TO_REMOVE})
 
# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
