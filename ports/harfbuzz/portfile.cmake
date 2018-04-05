include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO behdad/harfbuzz
    REF 1.7.6
    SHA512 90b51475d532377fe1686264a40f4a5555fc024f6984c1e3c114d8f4662e0c7f4a13e6a95e35fd5b3c54d1bb1b3cb97840b23f5ec2c6a799da61db1614b0fce3
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/0001-fix-uwp-build.patch"
        "${CMAKE_CURRENT_LIST_DIR}/find-package-freetype-2.patch"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_CMAKE_SYSTEM_NAME)
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
