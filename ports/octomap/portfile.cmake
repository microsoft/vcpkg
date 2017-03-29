include(vcpkg_common_functions)
set(GIT_REF "cefed0c1d79afafa5aeb05273cf1246b093b771c")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/octomap-${GIT_REF})
vcpkg_download_distfile(ARCHIVE
    URLS "https://codeload.github.com/OctoMap/octomap/zip/${GIT_REF}"
    FILENAME "octomap-${GIT_REF}.zip"
    SHA512 0d470ea9929a80366314a6e99717f68f489e8b58f26ae79bd02b7c1a4f1d8ee64591d61d95154724caefc5a0b71e1dab96a1280d9ff927c6e4d854b25b509295
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_OCTOVIS_SUBPROJECT=OFF -DBUILD_DYNAMICETD3D_SUBPROJECT=OFF -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/binvox2bt.exe ${CURRENT_PACKAGES_DIR}/tools/binvox2bt.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/bt2vrml.exe ${CURRENT_PACKAGES_DIR}/tools/bt2vrml.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/compare_octrees.exe ${CURRENT_PACKAGES_DIR}/tools/compare_octrees.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/convert_octree.exe ${CURRENT_PACKAGES_DIR}/tools/convert_octree.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/edit_octree.exe ${CURRENT_PACKAGES_DIR}/tools/edit_octree.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/eval_octree_accuracy.exe ${CURRENT_PACKAGES_DIR}/tools/eval_octree_accuracy.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/graph2tree.exe ${CURRENT_PACKAGES_DIR}/tools/graph2tree.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/log2graph.exe ${CURRENT_PACKAGES_DIR}/tools/log2graph.exe)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/binvox2bt.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/bt2vrml.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/compare_octrees.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/convert_octree.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/edit_octree.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/eval_octree_accuracy.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/graph2tree.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/log2graph.exe)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/octomap/octomap-targets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/octomap/octomap-targets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/octomap/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/octomap)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/octomap/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/octomap/copyright)