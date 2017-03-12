#tool
include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v3.2.0/protobuf-cpp-3.2.0.tar.gz"
    FILENAME "protobuf-cpp-3.2.0.tar.gz"
    SHA512 dd005f5e862ff24bb233b9eaed1d7f44c42f1cc8c647c0839fe2ecc2d91178845195d79776cfa2e31d224c16eed11b05ad824b66b743e685334057d8180f17aa
)
vcpkg_download_distfile(TOOL_ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v3.2.0/protoc-3.2.0-win32.zip"
    FILENAME "protoc-3.2.0-win32.zip"
    SHA512 985c86a04cebacfba96f3985d1b3d6ef341470171b809c6f6362bc13a07a3df9c8962d912857bb764bf8634cf676c5f8453c43b4e0a6398f2ff314708975d1e4
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE} ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.2.0-win32)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.2.0/cmake
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
        -Dprotobuf_WITH_ZLIB=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR=share/protobuf
)

# Using 64-bit toolset to avoid occassional Linker Out-of-Memory issues.
vcpkg_install_cmake(MSVC_64_TOOLSET)

# It appears that at this point the build hasn't actually finished. There is probably
# a process spawned by the build, therefore we need to wait a bit.

function(protobuf_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" RELEASE_MODULE "${RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)
protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.2.0/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/protobuf-3.2.0-win32/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_pdbs()
