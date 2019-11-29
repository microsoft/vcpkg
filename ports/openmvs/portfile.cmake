include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF v1.0
    SHA512 d5743660286068d2ec9e80b8cfdf1dd612d76f12f1f10c95d32bab55ae65032a200d820f2c76e4781068c61597e2533df8755fd5d9076d3aac9223134eb5b561
    HEAD_REF master
    PATCHES
        glfw3_target_compat.patch
        boost-1.71.patch
        cgal-5.0.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOpenMVS_USE_BREAKPAD=OFF
        -DOpenMVS_USE_CUDA=OFF
        -DINSTALL_CMAKE_DIR:STRING=share/openmvs
        -DINSTALL_BIN_DIR:STRING=bin
        -DINSTALL_LIB_DIR:STRING=lib
        -DINSTALL_INCLUDE_DIR:STRING=include
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/openmvs)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openmvs)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmvs RENAME copyright)
