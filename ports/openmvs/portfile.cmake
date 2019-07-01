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
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/CMake/OpenMVS)
endif()

#somehow the native CMAKE_EXECUTABLE_SUFFIX does not work, so here we emulate it
if(CMAKE_HOST_WIN32)
set(EXECUTABLE_SUFFIX ".exe")
else()
set(EXECUTABLE_SUFFIX "")
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/DensifyPointCloud${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/InterfaceCOLMAP${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/InterfaceVisualSFM${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/ReconstructMesh${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/RefineMesh${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/OpenMVS/TextureMesh${EXECUTABLE_SUFFIX})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/openmvs/)
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/DensifyPointCloud${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/DensifyPointCloud${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/DensifyPointCloud${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/InterfaceCOLMAP${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/InterfaceCOLMAP${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/InterfaceCOLMAP${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/InterfaceVisualSFM${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/InterfaceVisualSFM${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/InterfaceVisualSFM${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/ReconstructMesh${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/ReconstructMesh${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/ReconstructMesh${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/RefineMesh${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/RefineMesh${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/RefineMesh${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/OpenMVS/TextureMesh${EXECUTABLE_SUFFIX}")
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/OpenMVS/TextureMesh${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openmvs/TextureMesh${EXECUTABLE_SUFFIX})
endif()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openmvs)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmvs RENAME copyright)
