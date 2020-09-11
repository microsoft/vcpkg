vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF 519d6d9093819b6cf89ffff589a27ef8f83d0f65 # v0.1.5
    SHA512 3079786d106b98ba3b8c254c26ec4d9accf5fba5bcc13aed30ffa897e17ea7d701e6b6e903b37534e32e1cf0cac3e9a6ff46e1340ed7c530c2fc6262b245e05c
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
    OPTIONS -DSTATIC_CRT=${STATIC_CRT_LNK}
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