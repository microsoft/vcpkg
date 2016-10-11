include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v3.0.2/protobuf-cpp-3.0.2.tar.gz"
    FILENAME "protobuf-cpp-3.0.2.tar.gz"
    SHA512 5c99fa5d20815f9333a1e30d4da7621375e179abab6e4369ef0827b6ea6a679afbfec445dda21a72b4ab11e1bdd72c0f17a4e86b153ea8e2d3298dc3bcfcd643
)
vcpkg_download_distfile(TOOL_ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v3.0.2/protoc-3.0.2-win32.zip"
    FILENAME "protoc-3.0.2-win32.zip"
    SHA512 51c67bd8bdc35810da70786d873935814679c58b74e653923671bdf06b8b69a1c9a0793d090b17d25e91ddafff1726bcfcdd243373dd47c4aeb9ea83fbabaeb0
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE} ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.0.2-win32)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.0.2/cmake
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
        -Dprotobuf_WITH_ZLIB=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR=share/protobuf
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" RELEASE_MODULE "${RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.0.2/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.0.2-win32/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_pdbs()
