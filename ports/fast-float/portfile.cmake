vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF v0.8.0
    SHA512 d3f39457859ff0132f773222db3684f9b1d4a8ed549dfceb7cfb12d8f5871f5282dfa9eb01d39646cf93ed42dd640cb6487831ec15079b4b154f5002ac74edd7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/FastFloat TARGET_PATH share/FastFloat)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")