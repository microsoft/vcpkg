vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fastfloat/fast_float
    REF v0.7.0
    SHA512 26b8edd0a661dd64c9af76b01626a322a56a004df1cc707b4b9082ab5757dc74b29c12935c2dd4bbbbfed9692c78cf44b7498b3ca02e17ea123dd12edd261829
    HEAD_REF master
	PATCHES install_targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/FastFloat TARGET_PATH share/FastFloat)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")