include(vcpkg_common_functions)

set(SDL2_IMAGE_VERSION "2.0.4")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    FILENAME "SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    SHA512 b26ef2546718754481385ddad800ee61c84c58a9e141127c0a12215362d41c23603bfb21d556803396c0cb17bd7f48a45dd1b2e66573a1b2e32f590cc3fa48d0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SDL2_IMAGE_VERSION}    
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(USE_JPEG OFF)
if("libjpeg-turbo" IN_LIST FEATURES)
    set(USE_JPEG ON)
endif()

set(USE_TIFF OFF)
if("tiff" IN_LIST FEATURES)
    set(USE_TIFF ON)
endif()

set(USE_WEBP OFF)
if("libwebp" IN_LIST FEATURES)
    set(USE_WEBP ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
        -DUSE_PNG=ON
        -DUSE_JPEG=${USE_JPEG}
        -DUSE_TIFF=${USE_TIFF}
        -DUSE_WEBP=${USE_WEBP}
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-image)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-image/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-image/copyright)

vcpkg_copy_pdbs()