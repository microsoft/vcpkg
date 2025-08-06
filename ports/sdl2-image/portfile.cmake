vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_image
    REF "release-${VERSION}"
    SHA512 3fef846eb0ad51a8b346bb421c87eb81f0e2f186d700a219ebf17146397da404b3683853322989ed939b1672cc36b799582f24bc58a0393fc6c698a65cda2b82
    HEAD_REF main
    PATCHES 
        fix-findwebp.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        avif          SDL2IMAGE_AVIF
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

set(debug_libname "SDL2_imaged")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/SDL2_image.pc" "-lSDL2_image" "-lSDL2_image-static")
    set(debug_libname "SDL2_image-staticd")
endif()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/SDL2_image.pc" "-lSDL2_image" "-l${debug_libname}")
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/SDL2_image.framework"
    "${CURRENT_PACKAGES_DIR}/debug/SDL2_image.framework"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
