vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yazilimperver/sdl-painter
    REF "v${VERSION}"
    SHA512 fb4bfc044183cf5411a8c5d023f70208eaab0844ffac6f0cf18b1c321aa59a86ae6623c36c782aea7fef82f0a6ab0340c249e94e4a00dede1da61f060cab5f66
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
