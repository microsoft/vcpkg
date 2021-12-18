vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz"
    FILENAME "SDL2_net-2.0.1.tar.gz"
    SHA512 d27faee3cddc3592dae38947e6c1df0cbaa95f82fde9c87db6d11f6312d868cea74f6830ad07ceeb3d0d75e9424cebf39e54fddf9a1147e8d9e664609de92b7a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSDL_NET_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
