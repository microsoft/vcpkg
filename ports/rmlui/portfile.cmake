vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mikke89/RmlUi
    REF 4.0
    SHA512 b1c8dc48ce3c1ef8e53c7e8d0aa830eec5b968bb3ff7cd778067627de649b45c1a72adfcd168d0ca36018455b6b2a740324cec63304ec4e66dd859ef9d64f674
    HEAD_REF master
	PATCHES 
       fix-uwp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        lua             BUILD_LUA_BINDINGS
    INVERTED_FEATURES
        freetype        NO_FONT_INTERFACE_DEFAULT
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH    lib/RmlUi/cmake
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/RmlUi
	${CURRENT_PACKAGES_DIR}/lib/RmlUi
)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
