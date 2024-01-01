set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program bazel)
set(program_version 5.2.0)

if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "This is a host only port!")
endif()

if(VCPKG_TARGET_IS_LINUX)
    set(tool_subdirectory "${program_version}-linux")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-arm64")
        set(download_filename "bazel-${tool_subdirectory}-arm64")
        set(raw_executable ON)
        set(download_sha512 11e953717f0edd599053a9c6ab849c266f6b34cd6f39dd99301a138aeb9d10113d055f7a2452f6ae601a9e9c19c816d22732958bb147e493dae9c63b13e0f1e0)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64")
        set(download_filename "bazel-${tool_subdirectory}-x86_64")
        set(raw_executable ON)
        set(download_sha512 c9f117414f31bc85a1f6a91f3d1c0a4884a4bb346bb60b00599c2da8225d085f67bc865f1429c897681cb99471767171aed148c77ce80d9525841c873d9cc912)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    set(tool_subdirectory "${program_version}-darwin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-arm64")
        set(download_filename "bazel-${tool_subdirectory}-arm64")
        set(raw_executable ON)
        set(download_sha512 303b5c897eab93fb164dda53ecf6294fd3376a5de17a752388f4e7f612a8a537acc7d99a021ca616c1d7989d10c3c14cd87689dad60b9f654bf75ecc606bb23e)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64")
        set(download_filename "bazel-${tool_subdirectory}-x86_64")
        set(raw_executable ON)
        set(download_sha512 609db0a2f9d6eab292271b44acf08978159ca43a90f3228e32afe430e830f5418a041480d75e5b502be192897693f6b80a9ab9e7ce549e3655e188c39d29baaf)
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(tool_subdirectory "${program_version}-windows")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-arm64.exe")
        set(download_filename "bazel-${tool_subdirectory}-arm64.exe")
        set(download_sha512 02c8f331daa3ea37319cf06d96618f433e297f749a1a6de863d243e2b826bfb12c058696cd6216afe38d35177f52cc1c66af98a8bcb191e198f436a44f2c2a1a)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64.exe")
        set(download_filename "bazel-${tool_subdirectory}-x86_64.exe")
        set(download_sha512 4917dd714345359c24e40451e20862b2ed705824ceffe536d42e56ffcd66fcea581317857dfb5339b56534b0681efd8376e8eebdcf9daff0d087444b060bdc53)
    endif()
endif()

vcpkg_download_distfile(archive_path
    URLS ${download_urls}
    SHA512 "${download_sha512}"
    FILENAME "${download_filename}"
)
message(STATUS "archive_path: '${archive_path}'")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(INSTALL "${archive_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools"
    RENAME "${program}"
    FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)
