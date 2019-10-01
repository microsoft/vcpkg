include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF v0.1.4
    SHA512 cef20913077354fb0d52a40e9b9a428ae9290ab35c83962427d992c3bd543b4531b452bcccf9d92416b4d23138ffed39f0792d3a625d20c0ed04d784cc109418
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
