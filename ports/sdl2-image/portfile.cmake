set(SDL2_IMAGE_VERSION "2.0.5")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    FILENAME "SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    SHA512 c10e28a0d50fb7a6c985ffe8904370ab4faeb9bbed6f2ffbc81536422e8f8bb66eddbf69b12423082216c2bcfcb617cba4c5970f63fe75bfacccd9f99f02a6a2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SDL2_IMAGE_VERSION}
    PATCHES
        0001-sdl2-image-potentially-uninitialized_local-pointer-variable-start.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
        -DUSE_PNG=ON
        -DUSE_JPEG=${USE_JPEG}
        -DUSE_TIFF=${USE_TIFF}
        -DUSE_WEBP=${USE_WEBP}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
