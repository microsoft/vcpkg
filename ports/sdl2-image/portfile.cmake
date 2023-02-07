vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_image
    REF release-${VERSION}
    SHA512 3edf3643c144c8c6e11366a9a4f7a0d7c229065110464cfe413feaca53f6256b6e47b6f293324c1fdc9d9b50e6246cb4b84f961eed1e70d9469bd6c290bf64a4
    HEAD_REF main
    PATCHES
        fix-pkgconfig.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libjpeg-turbo SDL2IMAGE_JPG
        libwebp       SDL2IMAGE_WEBP
        tiff          SDL2IMAGE_TIF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDL2IMAGE_BACKEND_IMAGEIO=OFF
        -DSDL2IMAGE_BACKEND_STB=OFF
        -DSDL2IMAGE_DEPS_SHARED=OFF
        -DSDL2IMAGE_SAMPLES=OFF
        -DSDL2IMAGE_VENDORED=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_image CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL2_image.framework/Resources")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_image CONFIG_PATH SDL2_image.framework/Resources)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL2_image CONFIG_PATH lib/cmake/SDL2_image)
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/SDL2_image.framework"
    "${CURRENT_PACKAGES_DIR}/debug/SDL2_image.framework"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
