vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/brotli
    REF f4153a09f87cbb9c826d8fc12c74642bb2d879ea # v1.0.9+
    SHA512 7f48e794e738b31c2005e7cef6d8c0cc0d543f1cd8c137ae8ba14602cac2873de6299a3f32ad52be869f513e7548341353ed049609daef1063975694d9a9b80b
    HEAD_REF master
    PATCHES
        install.patch
        fix-arm-uwp.patch
        pkgconfig.patch
        fix-ios.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBROTLI_DISABLE_TESTS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/brotli)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-brotli TARGET_PATH share/unofficial-brotli)
vcpkg_fixup_pkgconfig()


file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-brotli)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
