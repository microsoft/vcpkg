vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 12944d5acf2d4e9b1106319080f31515aa46ba6eed4339d960bc79b10576cf4ff5d86e70687632f1efe4ccf1f4f6b6049ca181df8532428f66f2a1071f3412d5
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-disable-werror.patch
)

set(feature_options)
if("spdlog" IN_LIST FEATURES)
    list(APPEND feature_options "-DUSE_SPDLOG=ON")
else()
    list(APPEND feature_options "-DUSE_SPDLOG=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

vcpkg_copy_pdbs()
