
set(MODPLUG_HASH bb25b059a963f62aa0a3fe4c580da7da47f2b9c0)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libmodplug-${MODPLUG_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Konstanty/libmodplug/archive/${MODPLUG_HASH}.zip"
    FILENAME "libmodplug-0.8.8.5-${MODPLUG_HASH}"
    SHA512 65840b7748284b400dfe99775e18f44dcc4846bc0ff522d18b9ded42c7032e10683e453110d530722d9e22547b7e5f4878ebfff92f232691cbd5b0638c48d88b)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH})
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# don't package internal headers
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/include/it_defs.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/include/sndfile.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/include/stdafx.h)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/modplug.dll ${CURRENT_PACKAGES_DIR}/bin/modplug.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/modplug.dll ${CURRENT_PACKAGES_DIR}/debug/bin/modplug.dll)
    vcpkg_copy_pdbs()
else()
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/automagically-define-modplug-static.patch)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmodplug)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmodplug/COPYING ${CURRENT_PACKAGES_DIR}/share/libmodplug/copyright)
