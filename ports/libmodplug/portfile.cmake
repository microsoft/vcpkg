
set(MODPLUG_HASH 5a39f5913d07ba3e61d8d5afdba00b70165da81d)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libmodplug-${MODPLUG_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Konstanty/libmodplug/archive/${MODPLUG_HASH}.zip"
    FILENAME "libmodplug-${MODPLUG_HASH}.zip"
    SHA512 71b1314c44c98694c66ac17b638e997b99abc1ad61f7ac2e971000bdd4276d50d538259f4ee4dd39a3f672d28d3d322a32c83a9be0b1ffe5099ecc81273b5b55)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

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
