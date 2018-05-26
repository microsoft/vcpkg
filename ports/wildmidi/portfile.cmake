include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/wildmidi-wildmidi-0.4.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Mindwerks/wildmidi/archive/wildmidi-0.4.1.zip"
    FILENAME "wildmidi-0.4.1.zip"
    SHA512 ebfbb16b57c0d39f1402f91df4dd205d80f5632f6afbe5fa99af6f06279582f0676bb247cd64ec472cdf272f6a1a2917827ed98f9cc24166aa41f050b9f7d396
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-add-install-target.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-use-ansi.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED_LIBS "ON")
	set(WANT_STATIC "OFF")
else()
    set(BUILD_SHARED_LIBS "OFF")
	set(WANT_STATIC "ON")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC=ON
        -DWANT_PLAYER=OFF
        -DWANT_STATIC=${WANT_STATIC}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Rename library to get rid of _dynamic and _static suffix
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/wildmidi_dynamic.lib ${CURRENT_PACKAGES_DIR}/lib/wildmidi.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi_dynamic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/wildmidi_dynamic.dll ${CURRENT_PACKAGES_DIR}/bin/wildmidi.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/wildmidi_dynamic.dll ${CURRENT_PACKAGES_DIR}/debug/bin/wildmidi.dll)
else()
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/wildmidi_static.lib ${CURRENT_PACKAGES_DIR}/lib/wildmidi.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/wildmidi.lib)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/docs/license/LGPLv3.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wildmidi RENAME copyright)
