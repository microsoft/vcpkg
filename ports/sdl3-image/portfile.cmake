vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_image
    REF "release-${VERSION}"
    SHA512 365d3d332ddb7ac8d3675d19f04589164b8938c0d648ce1681a1c6d03dccb1185da34ac1c7110ce92926f59908d47c78f2296933c6afc05d0f42b16e04a1b9da
    HEAD_REF main
    PATCHES
        dependencies.diff
        pkgconfig-libname.diff
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jpeg    SDLIMAGE_JPG
        png     SDLIMAGE_PNG
        tiff    SDLIMAGE_TIF
        webp    SDLIMAGE_WEBP
    INVERTED_FEATURES
        # Disabled capabilities: Needing dependencies.
        core    SDLIMAGE_AVIF
        core    SDLIMAGE_JXL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDLIMAGE_BACKEND_IMAGEIO=OFF
        -DSDLIMAGE_BACKEND_STB=OFF
        -DSDLIMAGE_DEPS_SHARED=OFF
        -DSDLIMAGE_RELOCATABLE=ON
        -DSDLIMAGE_SAMPLES=OFF
        -DSDLIMAGE_STRICT=ON
        -DSDLIMAGE_VENDORED=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL3_image CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME SDL3_image CONFIG_PATH lib/cmake/SDL3_image)
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
