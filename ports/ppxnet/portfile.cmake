include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxnet
    REF v1.7
    SHA512 e30e1e5785d3bb0ff0c1e3ca119de78628e73fd9a9e6ce6e25c7264a18aaf2853b79e9b9d1044580e849b405bc7829cb2d0be296cba2d68a70e994f482725391
    HEAD_REF master
)


if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
	set(BUILD_SHARED_LIBS OFF)
else()
	set(BUILD_SHARED_LIBS ON)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_TESTS=OFF
	OPTIONS_RELEASE
	OPTIONS_DEBUG
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/ppxnet)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ppxnet)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/ppxnet)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/ppxnet)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ppxnet RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

