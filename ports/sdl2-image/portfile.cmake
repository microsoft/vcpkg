include(vcpkg_common_functions)
set(SDL2_IMAGE_VERSION "2.0.2")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2_image-${SDL2_IMAGE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    FILENAME "SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    SHA512 bf143bdbd3cb7cfad61b8dcc35950584304deac802bad6c0c8144e914401a5ddef01f674d2dc1214371d0f371f76e87a45873e2655947e8e1da83fb44d8285f4
)
vcpkg_extract_source_archive(${ARCHIVE})

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