include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxnet
    REF 21ec363d3af5d63227256d153da744d42b87dedc
    SHA512 55930729330845fd3df3a67b032833567917db08c4a75888623e795a462393fc74509c7c11a3808f530910bb77156cfa98ce6b162690058c45cf981af66445f5
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