vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yazilimperver/sdl-painter
    REF "v${VERSION}"
    SHA512 7f05eafbf4bed7162290739c17f45f9b6f34692a78d6c3026475ae3418ee77def88b6e4f088554fed269b3ac2de9cb6813d118663e4cadb908138b7c9228a779
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan SDLPAINTER_WITH_VULKAN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDLPAINTER_BUILD_EXAMPLES=OFF
        -DSDLPAINTER_BUILD_TESTS=OFF
        -DSDLPAINTER_WARNINGS_AS_ERRORS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sdl_painter CONFIG_PATH lib/cmake/sdl_painter)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
