
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2_ttf-2.0.14)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.14.tar.gz"
    FILENAME "SDL2_ttf-2.0.14.tar.gz"
    SHA512 4db817573fd216e26180f4c401cc869ce407589a461032fd7167dc612d35e038cca1ab67be7909b6b49c741581a68125ab46362ad8e3c0a2cdd39624ad847099)
	
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSDL_TTF_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf/copyright)
