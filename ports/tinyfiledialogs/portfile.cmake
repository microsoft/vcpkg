include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyfiledialogs-code-03d35a86696859128d41f8b967c1ef3e39c980ce)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/code-snapshots/git/t/ti/tinyfiledialogs/code.git/tinyfiledialogs-code-03d35a86696859128d41f8b967c1ef3e39c980ce.zip"
    FILENAME "tinyfiledialogs-code-03d35a86696859128d41f8b967c1ef3e39c980ce.zip"
    SHA512 69f96651c590b6349bc21980038c42d099260a454e485df87e03943258bd5f878402f04ed3a2349cf6bb0ea9672bbf150818502d2bf9cfdb2a5d10eaa8255262
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/zlib.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyfiledialogs RENAME copyright)
