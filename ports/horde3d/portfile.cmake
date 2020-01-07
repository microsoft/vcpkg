vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO horde3d/Horde3D
    REF v1.0.0
    SHA512 ec196f33ad1bd95e9429aeb02c346941ccb77b431c13ab50d2e9ba15d7581e53939d7e2bd252f5a245e3deb41e19c8c3609d5f56d6c53541c803c651c9b7dc01
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

file(REMOVE ${SOURCE_PATH}/CMake/Modules/FindGLFW.cmake)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
	
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)