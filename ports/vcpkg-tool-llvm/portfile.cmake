set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest_contents)
string(JSON version GET "${manifest_contents}" version)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(name LLVM-${version}-win32.exe)
    set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.1/${name}")
    set(hash 6df7b992d4c382c3e1c71ff30e43b9fa0311c33adfebc9feaa4ea7e2f50fdb836b04dbad529aac1a6f7bf0135b98ecf3291d0386152afbcaf5ac7cb4592a94fa)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(name LLVM-${version}-win64.exe)
    set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.1/${name}")
    set(hash 56e8871898fc2d62383b76b75ce7852a0179d70a1d327e95e73a115f1e09db5ceec1ae950279ddb0779de417eca9cdf7517d9c6a5498c7c17de6550aef16073d)
endif()
vcpkg_download_distfile(archive_path
    URLS "${url}"
    FILENAME "${name}" 
    SHA512 "${hash}"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
set(7Z "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-7zip/7z.exe")
vcpkg_execute_in_download_mode(
                        COMMAND "${7Z}" x "${archive_path}" "-o${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}" "-y" "-bso0" "-bsp0"
                        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
                    )
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/$PLUGINSDIR")

set(details "set(program_version \"${program_version}\")\n")
string(APPEND details "set(paths_to_search \"\${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/bin\")\n")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/details.cmake" "${details}")