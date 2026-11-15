vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(FASTLOESS_HAS_DEBUG_PACKAGE OFF)

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
            "fastloess prebuilt Windows archives require the MSVC ABI."
        )
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_PLATFORM windows-x64-msvc)
        set(FASTLOESS_DEBUG_PLATFORM windows-x64-msvc-debug)
        set(FASTLOESS_BINARY_NAME fastloess-win32-x64.dll)
        set(FASTLOESS_DEBUG_BINARY_NAME fastloess-win32-x64-debug.dll)
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_RELEASE_WINDOWS_X64_SHA512"
        )
        set(FASTLOESS_DEBUG_ARCHIVE_SHA512
            "REPLACE_WITH_DEBUG_WINDOWS_X64_SHA512"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_PLATFORM windows-arm64)
        set(FASTLOESS_DEBUG_PLATFORM windows-arm64-debug)
        set(FASTLOESS_BINARY_NAME fastloess-win32-arm64.dll)
        set(FASTLOESS_DEBUG_BINARY_NAME fastloess-win32-arm64-debug.dll)
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_RELEASE_WINDOWS_ARM64_SHA512"
        )
        set(FASTLOESS_DEBUG_ARCHIVE_SHA512
            "REPLACE_WITH_DEBUG_WINDOWS_ARM64_SHA512"
        )
    else()
        message(
            FATAL_ERROR
            "fastloess does not support Windows architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_HAS_DEBUG_PACKAGE ON)
    set(FASTLOESS_LIBRARY_DIR bin)
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_ARCH x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_ARCH arm64)
    else()
        message(
            FATAL_ERROR
            "fastloess does not support Linux architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_PLATFORM "linux-${FASTLOESS_ARCH}")
    set(FASTLOESS_BINARY_NAME "libfastloess-linux-${FASTLOESS_ARCH}.so")
    set(FASTLOESS_LIBRARY_DIR lib)
    if(FASTLOESS_ARCH STREQUAL "x64")
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_LINUX_X64_SHA512"
        )
    else()
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_LINUX_ARM64_SHA512"
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_ARCH x64)
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_MACOS_X64_SHA512"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_ARCH arm64)
        set(FASTLOESS_ARCHIVE_SHA512
            "REPLACE_WITH_MACOS_ARM64_SHA512"
        )
    else()
        message(
            FATAL_ERROR
            "fastloess does not support macOS architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_PLATFORM "macos-${FASTLOESS_ARCH}")
    set(FASTLOESS_BINARY_NAME "libfastloess-macos-${FASTLOESS_ARCH}.dylib")
    set(FASTLOESS_LIBRARY_DIR lib)
else()
    message(FATAL_ERROR "fastloess does not support this target platform.")
endif()

vcpkg_download_distfile(
    FASTLOESS_ARCHIVE
    URLS "https://github.com/thisisamirv/loess-project/releases/download/v${VERSION}/libfastloess-${FASTLOESS_PLATFORM}.tar"
    FILENAME "fastloess-v${VERSION}/libfastloess-${FASTLOESS_PLATFORM}.tar"
    SHA512 "${FASTLOESS_ARCHIVE_SHA512}"
)
vcpkg_extract_source_archive(
    FASTLOESS_PACKAGE_DIR
    ARCHIVE "${FASTLOESS_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

set(FASTLOESS_DEBUG_PACKAGE_DIR "")
if(FASTLOESS_HAS_DEBUG_PACKAGE)
    vcpkg_download_distfile(
        FASTLOESS_DEBUG_ARCHIVE
        URLS "https://github.com/thisisamirv/loess-project/releases/download/v${VERSION}/libfastloess-${FASTLOESS_DEBUG_PLATFORM}.tar"
        FILENAME "fastloess-v${VERSION}/libfastloess-${FASTLOESS_DEBUG_PLATFORM}.tar"
        SHA512 "${FASTLOESS_DEBUG_ARCHIVE_SHA512}"
    )
    vcpkg_extract_source_archive(
        FASTLOESS_DEBUG_PACKAGE_DIR
        ARCHIVE "${FASTLOESS_DEBUG_ARCHIVE}"
        NO_REMOVE_ONE_LEVEL
    )
endif()

if(VCPKG_TARGET_IS_OSX)
    vcpkg_execute_required_process(
        COMMAND
            install_name_tool
            -id
            "@rpath/${FASTLOESS_BINARY_NAME}"
            "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        WORKING_DIRECTORY "${FASTLOESS_PACKAGE_DIR}"
        LOGNAME "install-name-${FASTLOESS_PLATFORM}"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/loess-project
    REF "v${VERSION}"
    SHA512 "REPLACE_WITH_SOURCE_ARCHIVE_SHA512"
)

set(FASTLOESS_CMAKE_OPTIONS
    "-DFASTLOESS_VERSION=${VERSION}"
    "-DFASTLOESS_PACKAGE_DIR=${FASTLOESS_PACKAGE_DIR}"
    "-DFASTLOESS_BINARY_NAME=${FASTLOESS_BINARY_NAME}"
    "-DFASTLOESS_LIBRARY_DIR=${FASTLOESS_LIBRARY_DIR}"
)
if(FASTLOESS_HAS_DEBUG_PACKAGE)
    list(
        APPEND FASTLOESS_CMAKE_OPTIONS
        "-DFASTLOESS_DEBUG_PACKAGE_DIR=${FASTLOESS_DEBUG_PACKAGE_DIR}"
        "-DFASTLOESS_DEBUG_BINARY_NAME=${FASTLOESS_DEBUG_BINARY_NAME}"
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(
        APPEND FASTLOESS_CMAKE_OPTIONS
        "-DFASTLOESS_ARCH=${VCPKG_TARGET_ARCHITECTURE}"
    )
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS ${FASTLOESS_CMAKE_OPTIONS}
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
