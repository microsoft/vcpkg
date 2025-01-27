vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_image
    REF "prerelease-${VERSION}"
    SHA512 d11764142798e9c3cbb2fcfb123a5d6e5192d45011118f5a76f63b9ba100119799aacf9cd64835a9c504d3040116202f44aba9df1fc851afc1fdfb3b498c56a2
    HEAD_REF main
    PATCHES
        cmake-sdl3.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libjpeg-turbo SDLIMAGE_JPG
        libwebp       SDLIMAGE_WEBP
        tiff          SDLIMAGE_TIF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDLIMAGE_BACKEND_IMAGEIO=OFF
        -DSDLIMAGE_BACKEND_STB=OFF
        -DSDLIMAGE_DEPS_SHARED=OFF
        -DSDLIMAGE_SAMPLES=OFF
        -DSDLIMAGE_VENDORED=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL3_image CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL3_image.framework/Resources")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL3_image CONFIG_PATH SDL3_image.framework/Resources)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL3_image CONFIG_PATH lib/cmake/SDL3_image)
endif()

vcpkg_fixup_pkgconfig()

if(NOT VCPKG_TARGET_IS_LINUX AND NOT VCPKG_TARGET_IS_ANDROID AND NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/SDL3-image.pc" "-lSDL3_image" "-lSDL3_imaged")
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/SDL3_image.framework"
    "${CURRENT_PACKAGES_DIR}/debug/SDL3_image.framework"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
