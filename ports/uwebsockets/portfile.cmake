include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-0.12.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v0.12.0.zip"
    FILENAME "uwebsockets-v0.12.0.zip"
    SHA512 ea10682608d5f6c8b246f186dfc2f14f496858cc7e468880b96b111f10058daf529f1aa9662a851e21494dde9a4faadf2b9904483dac5350d0ca8736500cdda8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)
vcpkg_copy_pdbs()
