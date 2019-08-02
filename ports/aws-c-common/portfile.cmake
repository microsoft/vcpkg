vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF v0.4.3
    SHA512 dadc3e1059a0bb80fee726e87a7154b50bc30c4aa0404ea8d48966981935863d3f0d6ad9f68c7890ba346cb10f75c34b3edc2f1c3e051a1deb615e973f379d97
    HEAD_REF master
)

if (${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
  set(USE_STATIC ON)
else()
  set(USE_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSTATIC_CRT=${USE_STATIC}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-common/cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/cmake)
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-common
	${CURRENT_PACKAGES_DIR}/lib/aws-c-common
	)
vcpkg_copy_pdbs()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-c-common RENAME copyright)
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/share
)