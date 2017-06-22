include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/20170423/glew-2.0.0)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://sourceforge.net/projects/glew/files/glew/snapshots/glew-20170423.tgz"
    FILENAME "glew-20170423.tgz"
    SHA512 2d4651196e01b4db7b210fc60505bf50ac9e37b49c8eee9c9bbfeadb4cb6f87f4c907e60e708a7371ff4b7596bee51ed35a76fba76f9a13a1f32f123121f1350
)
vcpkg_extract_source_archive(${ARCHIVE_FILE} ${CURRENT_BUILDTREES_DIR}/src/20170423)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/glew")

foreach(FILE ${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-release.cmake)
    file(READ ${FILE} _contents)
    string(REPLACE "libglew32" "glew32" _contents "${_contents}")
    file(WRITE ${FILE} "${_contents}")
endforeach()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/libglew32.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libglew32.lib ${CURRENT_PACKAGES_DIR}/lib/glew32.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libglew32d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/glew32d.lib)
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/glewinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/visualinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/glewinfo.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/visualinfo.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)