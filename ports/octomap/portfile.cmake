vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OctoMap/octomap
    REF cefed0c1d79afafa5aeb05273cf1246b093b771c
    SHA512 8fdea8b33680488d41e570d55ff88c20b923efb9d48238031f9b96d2e3917dbe7e49699769de63794f4b1d24e40a99615151e72487f30de340a3abf6522ea156
    HEAD_REF master
    PATCHES
      "001-fix-exported-targets.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_OCTOVIS_SUBPROJECT=OFF
        -DBUILD_DYNAMICETD3D_SUBPROJECT=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_tools(
    TOOL_NAMES binvox2bt bt2vrml compare_octrees convert_octree edit_octree eval_octree_accuracy graph2tree log2graph
    AUTO_CLEAN)

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/octomap")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/octomap/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
