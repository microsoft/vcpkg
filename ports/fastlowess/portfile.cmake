vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(FASTLOWESS_HAS_DEBUG_PACKAGE OFF)

if(VCPKG_TARGET_IS_WINDOWS)
    # Rust's MSVC stdlib is built against the release CRT (/MD). Even the
    # upstream debug-c profile therefore links VCRUNTIME140.dll, not
    # VCRUNTIME140D.dll. Separate Debug/Release DLLs are still published
    # (optimization and debug info differ); skip the post-build CRT check
    # the same way ports/rerun-sdk does for its prebuilt Rust cdylib.
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
    if(VCPKG_TARGET_IS_MINGW)
        message(
            FATAL_ERROR
            "fastlowess prebuilt Windows archives require the MSVC ABI."
        )
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_PLATFORM windows-x64-msvc)
        set(FASTLOWESS_DEBUG_PLATFORM windows-x64-msvc-debug)
        set(FASTLOWESS_BINARY_NAME fastlowess-win32-x64.dll)
        set(FASTLOWESS_DEBUG_BINARY_NAME fastlowess-win32-x64-debug.dll)
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_RELEASE_WINDOWS_X64_SHA512"
        )
        set(FASTLOWESS_DEBUG_ARCHIVE_SHA512
            "REPLACE_WITH_DEBUG_WINDOWS_X64_SHA512"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_PLATFORM windows-arm64)
        set(FASTLOWESS_DEBUG_PLATFORM windows-arm64-debug)
        set(FASTLOWESS_BINARY_NAME fastlowess-win32-arm64.dll)
        set(FASTLOWESS_DEBUG_BINARY_NAME fastlowess-win32-arm64-debug.dll)
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_RELEASE_WINDOWS_ARM64_SHA512"
        )
        set(FASTLOWESS_DEBUG_ARCHIVE_SHA512
            "REPLACE_WITH_DEBUG_WINDOWS_ARM64_SHA512"
        )
    else()
        message(
            FATAL_ERROR
            "fastlowess does not support Windows architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOWESS_HAS_DEBUG_PACKAGE ON)
    set(FASTLOWESS_LIBRARY_DIR bin)
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_ARCH x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_ARCH arm64)
    else()
        message(
            FATAL_ERROR
            "fastlowess does not support Linux architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOWESS_PLATFORM "linux-${FASTLOWESS_ARCH}")
    set(FASTLOWESS_BINARY_NAME "libfastlowess-linux-${FASTLOWESS_ARCH}.so")
    set(FASTLOWESS_LIBRARY_DIR lib)
    if(FASTLOWESS_ARCH STREQUAL "x64")
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_LINUX_X64_SHA512"
        )
    else()
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_LINUX_ARM64_SHA512"
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_ARCH x64)
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_MACOS_X64_SHA512"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_ARCH arm64)
        set(FASTLOWESS_ARCHIVE_SHA512
            "REPLACE_WITH_MACOS_ARM64_SHA512"
        )
    else()
        message(
            FATAL_ERROR
            "fastlowess does not support macOS architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOWESS_PLATFORM "macos-${FASTLOWESS_ARCH}")
    set(FASTLOWESS_BINARY_NAME "libfastlowess-macos-${FASTLOWESS_ARCH}.dylib")
    set(FASTLOWESS_LIBRARY_DIR lib)
else()
    message(FATAL_ERROR "fastlowess does not support this target platform.")
endif()

vcpkg_download_distfile(
    FASTLOWESS_ARCHIVE
    URLS "https://github.com/thisisamirv/lowess-project/releases/download/v${VERSION}/libfastlowess-${FASTLOWESS_PLATFORM}.tar"
    FILENAME "fastlowess-v${VERSION}/libfastlowess-${FASTLOWESS_PLATFORM}.tar"
    SHA512 "${FASTLOWESS_ARCHIVE_SHA512}"
)
vcpkg_extract_source_archive(
    FASTLOWESS_PACKAGE_DIR
    ARCHIVE "${FASTLOWESS_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

set(FASTLOWESS_DEBUG_PACKAGE_DIR "")
if(FASTLOWESS_HAS_DEBUG_PACKAGE)
    vcpkg_download_distfile(
        FASTLOWESS_DEBUG_ARCHIVE
        URLS "https://github.com/thisisamirv/lowess-project/releases/download/v${VERSION}/libfastlowess-${FASTLOWESS_DEBUG_PLATFORM}.tar"
        FILENAME "fastlowess-v${VERSION}/libfastlowess-${FASTLOWESS_DEBUG_PLATFORM}.tar"
        SHA512 "${FASTLOWESS_DEBUG_ARCHIVE_SHA512}"
    )
    vcpkg_extract_source_archive(
        FASTLOWESS_DEBUG_PACKAGE_DIR
        ARCHIVE "${FASTLOWESS_DEBUG_ARCHIVE}"
        NO_REMOVE_ONE_LEVEL
    )
endif()

if(VCPKG_TARGET_IS_OSX)
    vcpkg_execute_required_process(
        COMMAND
            install_name_tool
            -id
            "@rpath/${FASTLOWESS_BINARY_NAME}"
            "${FASTLOWESS_PACKAGE_DIR}/${FASTLOWESS_BINARY_NAME}"
        WORKING_DIRECTORY "${FASTLOWESS_PACKAGE_DIR}"
        LOGNAME "install-name-${FASTLOWESS_PLATFORM}"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/lowess-project
    REF "v${VERSION}"
    SHA512 "REPLACE_WITH_SOURCE_ARCHIVE_SHA512"
)

set(FASTLOWESS_CMAKE_OPTIONS
    "-DFASTLOWESS_VERSION=${VERSION}"
    "-DFASTLOWESS_PACKAGE_DIR=${FASTLOWESS_PACKAGE_DIR}"
    "-DFASTLOWESS_BINARY_NAME=${FASTLOWESS_BINARY_NAME}"
    "-DFASTLOWESS_LIBRARY_DIR=${FASTLOWESS_LIBRARY_DIR}"
)
if(FASTLOWESS_HAS_DEBUG_PACKAGE)
    list(
        APPEND FASTLOWESS_CMAKE_OPTIONS
        "-DFASTLOWESS_DEBUG_PACKAGE_DIR=${FASTLOWESS_DEBUG_PACKAGE_DIR}"
        "-DFASTLOWESS_DEBUG_BINARY_NAME=${FASTLOWESS_DEBUG_BINARY_NAME}"
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(
        APPEND FASTLOWESS_CMAKE_OPTIONS
        "-DFASTLOWESS_ARCH=${VCPKG_TARGET_ARCHITECTURE}"
    )
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS ${FASTLOWESS_CMAKE_OPTIONS}
)
vcpkg_cmake_install()
file(
    REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-APACHE"
)
file(
    INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
