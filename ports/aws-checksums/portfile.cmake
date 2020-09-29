vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF fb96b3e964fe9bde2625c3ac9547e54d6c802211 # v0.1.9
    SHA512 2cf63a462c900fae8ad101ecac8be6fd6ce3f796e3cecc1b3d19ffba364030d7468a7c7beab91594d2521cab5e99765c7b67fa2fef6f772457e04f75f59962cc
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_CRT_LNK ON)
else()
    set(STATIC_CRT_LNK OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC_CRT=${STATIC_CRT_LNK}
        -DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common # use extra cmake files
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-checksums/cmake)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-checksums
	${CURRENT_PACKAGES_DIR}/lib/aws-checksums
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)