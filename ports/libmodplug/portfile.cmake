
set(MODPLUG_HASH c855db2a0938aaac4bd686a345e0d1b09564f181)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libmodplug-${MODPLUG_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/JackBister/libmodplug/archive/${MODPLUG_HASH}.zip"
    FILENAME "libmodplug-${MODPLUG_HASH}.zip"
    SHA512 68ceb84e891e076d673d1886169d0c926e833a56dc5371f8012a4e2a9aa2de44dabdddf2df021c5498f61a951e52f3a2b77f2c7f487b79ab9e3dac483609f4af)

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
