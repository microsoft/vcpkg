include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mindwerks/wildmidi
    REF wildmidi-0.4.1
    SHA512 ac95b901d2eca88118d70ec5f8ddb4a52ed9ffbd90ae1c8837352d22e27da0d5f56e4e79615cbac9683303b3488a9fa45b60d77e28f698277f1e4c3fc9e3d165
    HEAD_REF master
    PATCHES
        0001-add-install-target.patch
        0002-use-ansi.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(WANT_STATIC "OFF")
else()
	set(WANT_STATIC "ON")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWANT_PLAYER=OFF
        -DWANT_STATIC=${WANT_STATIC}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Rename library to get rid of _dynamic and _static suffix
if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/wildmidi_dynamic.lib ${CURRENT_PACKAGES_DIR}/lib/wildmidi.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi_dynamic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/wildmidi_dynamic.dll ${CURRENT_PACKAGES_DIR}/bin/wildmidi.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/wildmidi_dynamic.dll ${CURRENT_PACKAGES_DIR}/debug/bin/wildmidi.dll)
    else()
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/wildmidi_static.lib ${CURRENT_PACKAGES_DIR}/lib/wildmidi.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi.lib)
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/docs/license/LGPLv3.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wildmidi RENAME copyright)
