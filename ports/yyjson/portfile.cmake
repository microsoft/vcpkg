vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ibireme/yyjson
    REF c3a1f1f54a517dc15ba8670d969c0acdfabcd039
    SHA512 57d75ee51826f6cf8e583038ec39642e469558bdc3485d6ac5173d6dc293c48055af11fcb0c9c0be3ce782af50bb8c8453f3fec89d4450e3003c2a62237d76de
    HEAD_REF master
    PATCHES
        cmake-install.patch
        fix-uwp-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
	    -DYYJSON_BUILD_TESTS=OFF
	    -DYYJSON_BUILD_MISC=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
