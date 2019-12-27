include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxnet
    REF v1.14
    SHA512 ac23e738036b4236ebc19a4c944ef2d71fd1ed5b4f15efc522d9d76e3f60c857e5c6f9c999790f31cf4a2e3b58996435c084f0ff5b1348300b8d444f40ee981e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
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