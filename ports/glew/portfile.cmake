include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glew-2.0.0)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://sourceforge.net/projects/glew/files/glew/snapshots/glew-20170423.tgz"
    FILENAME "glew-20170423.tgz"
    SHA512 2d4651196e01b4db7b210fc60505bf50ac9e37b49c8eee9c9bbfeadb4cb6f87f4c907e60e708a7371ff4b7596bee51ed35a76fba76f9a13a1f32f123121f1350
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/glew")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/glewinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/visualinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/glewinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/visualinfo.exe)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)