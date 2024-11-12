include_guard(GLOBAL)

find_program(pwsh_exe NAMES pwsh powershell)

execute_process(
    COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -Command "${CMAKE_CURRENT_LIST_DIR}/env-cleanup.ps1"
)
cmake_path(GET pwsh_exe PARENT_PATH pwsh_path)

set(systemroot "$ENV{SystemRoot}")
string(REPLACE "\\" "/" systemroot "${systemroot}")

set(PATH_VAR 
    ${pwsh_path}
    "${systemroot}/system32"
    "${systemroot}"
    "${systemroot}/System32/Wbem"
    "${systemroot}/System32/WindowsPowerShell/v1.0/"
)

cmake_path(CONVERT "${PATH_VAR}" TO_NATIVE_PATH_LIST ENV{PATH} NORMALIZE)

if(EXISTS "${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/share/msvc/msvc-env.cmake")
    message("Loading MSVC environment ....")
    include("${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/share/msvc/msvc-env.cmake")
endif()