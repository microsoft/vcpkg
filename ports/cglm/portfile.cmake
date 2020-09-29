vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO recp/cglm
    REF v0.7.8
    SHA512 1fd5db117f22899dbbb3e7c8ab452476293b155df96a34b4319a57991d2361a210d8e29d015c14cbdbcaa80440cddc3ed4c8d5930a2f2ed11853b02f60796e55
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS 
		-DCGLM_SHARED=OFF
		-DCGLM_STATIC=ON 
    #  -DCGLM_USE_C99=ON
    #  -DCGLM_USE_TEST=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cglm/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cglm RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cglm")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cglm")
configure_file(${CMAKE_CURRENT_LIST_DIR}/cglm-config.cmake  ${CURRENT_PACKAGES_DIR}/share/cglm COPYONLY)
