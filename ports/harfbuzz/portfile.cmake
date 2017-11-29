include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO behdad/harfbuzz
    REF 1.7.1
    SHA512 af25a393f0401e04647b8bc508cfed3cea399522e2932631d87f45127b7f975bfd9d896b1e3104a97f4b69b3e0e8a001173fbee0af0c559cd580d4aa5cd8d04d
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-uwp-build.patch"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    SET(HAVE_GLIB "OFF")
    SET(BUILTIN_UCDN "ON")
else()
    SET(HAVE_GLIB "ON")
    SET(BUILTIN_UCDN "OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_HAVE_FREETYPE=ON
        -DHB_HAVE_GLIB=${HAVE_GLIB}
        -DHB_BUILTIN_UCDN=${BUILTIN_UCDN}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/harfbuzz/COPYING ${CURRENT_PACKAGES_DIR}/share/harfbuzz/copyright)
