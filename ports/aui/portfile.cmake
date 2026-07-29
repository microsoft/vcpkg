vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aui-framework/aui
    REF "v${VERSION}"
    SHA512 decac6cebb6003791896e8d7a9fd7334351aa30205eac787cdbb51d1da657cda140178e0b8f5d236b42a4c1f37633141fb869784e5fc5c9718b5396e077afe7d
    HEAD_REF master
    PATCHES
        debundle.patch
)

vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/aui.build.cmake"
    [[macro(aui_enable_tests AUI_MODULE_NAME)]]
    [[macro(aui_enable_tests AUI_MODULE_NAME)
        return()]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/aui.build.cmake"
    [[macro(aui_enable_benchmarks AUI_MODULE_NAME)]]
    [[macro(aui_enable_benchmarks AUI_MODULE_NAME)
        return()]]
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF
        -DAUIB_NO_PRECOMPILED=TRUE
        -DAUIB_DISABLE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

#vcpkg_cmake_config_fixup(PACKAGE_NAME AudioFile CONFIG_PATH lib/cmake/AudioFile)

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
