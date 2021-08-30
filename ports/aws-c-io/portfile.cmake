vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-io
    REF 57b00febac48e78f8bf8cff4c82a249e6648842a # v0.10.7
    SHA512 b92ae3cb14d26dfe48cb903df56f7df91a4dc0ab2e5ea4f095c72b0b7e0a2582f1324c73eb42c080bcb0a59a3dfc37cd2912037fc8e5f7df8433899749fca63c
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
        -DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common # use extra cmake files
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-io/cmake)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-io
	${CURRENT_PACKAGES_DIR}/lib/aws-c-io
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
