include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF v0.1.3
    SHA512 79bf71a6c4c268b27efe8a6a3c4b90281da4ce7f6e4c1c62fce80b11a4756ecfd4dc2b19624ace3f54137113d0cb56a517de0b91dd6338ee8ca069756bca13f4
    HEAD_REF master
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

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-checksums RENAME copyright)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/share
)