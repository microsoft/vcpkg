vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_image
    REF "release-${VERSION}"
    SHA512 bd2b1c8abdf5b207901fa76f6636830f813b67f3e6854e623af6c7fbd27cf34e0d9f3d62f5eaf8b269fb0e1fbb309adad0e1ce9b55da01db5fbe0f21fb7f93b4
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
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=OFF
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
