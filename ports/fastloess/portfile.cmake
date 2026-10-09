vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
    if(VCPKG_TARGET_IS_MINGW)
        message(
            FATAL_ERROR
            "fastloess prebuilt Windows archives require the MSVC ABI."
        )
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_PLATFORM windows-x64-msvc)
        set(FASTLOESS_BINARY_NAME fastloess-win32-x64.dll)
        set(FASTLOESS_IMPORT_LIBRARY_NAME fastloess-win32-x64.lib)
        set(FASTLOESS_ARCHIVE_SHA512
            c3359f2c9d2709b1674a9b52ee7c076a97de4084466c4a39b454b33487d9af857d0ff2a41ce09f52bc3552632b67df49075534a822d89d137212c5dabb53d23b
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_PLATFORM windows-arm64)
        set(FASTLOESS_BINARY_NAME fastloess-win32-arm64.dll)
        set(FASTLOESS_IMPORT_LIBRARY_NAME fastloess-win32-arm64.lib)
        set(FASTLOESS_ARCHIVE_SHA512
            4a5d3dabd8cd7ef65caa6023b635db79770faf06eeb2d8206ebd28e76d5f0b81ed38c4658cba90423823a9eba79eea3757037117ca15885b2949935a344d9359
        )
    else()
        message(
            FATAL_ERROR
            "fastloess does not support Windows architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
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
    set(FASTLOESS_BINARY_NAME
        "libfastloess-linux-${FASTLOESS_ARCH}.so"
    )
    set(FASTLOESS_LIBRARY_DIR lib)
    if(FASTLOESS_ARCH STREQUAL "x64")
        set(FASTLOESS_ARCHIVE_SHA512
            d4aa56432c36db5367b80c55a6a1d872c7d41e694948ed6188d1ae9ca3ad06a7f3b3184983df6c2267c9bf714f27da946d06afe6df4089f402bc398702192685
        )
    else()
        set(FASTLOESS_ARCHIVE_SHA512
            357f8d7e662a47aa28a694244edff99c57911141dbb97792e47f1860451a439d1383c5055d98cac5202d8ecad0126cb8919e92fb6bafa0767732ef5fd74b5d9f
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_ARCH x64)
        set(FASTLOESS_ARCHIVE_SHA512
            e4778831e70dbfcd021429f560784032fd8c9dec40cac24fb6e7a82e66d53ecc7b2cfc72f3a90908e18b4493114b788653d2257adfdfd3b74208958431d88dd0
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_ARCH arm64)
        set(FASTLOESS_ARCHIVE_SHA512
            603f4552ae90f43c2dec0b11e9413c7226099f6a7f2191bdc2d79415eb27960a7c9517d00b1d42d74a0a68341ebb7506480148cf044ef72c4bb02a6fb2f13e46
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
    SHA512 b3a2df5847a4683b3f262612fe476f6ebc5ef336a779738140597a15ccac138f5786695f909b0b877afdc4635b7659441ece2cae7d2f45393f21d3905fe4cb8b
)

set(FASTLOESS_CMAKE_OPTIONS
    "-DFASTLOESS_VERSION=${VERSION}"
    "-DFASTLOESS_PACKAGE_DIR=${FASTLOESS_PACKAGE_DIR}"
    "-DFASTLOESS_BINARY_NAME=${FASTLOESS_BINARY_NAME}"
    "-DFASTLOESS_LIBRARY_DIR=${FASTLOESS_LIBRARY_DIR}"
    "-DFASTLOESS_IMPORT_LIBRARY_NAME=${FASTLOESS_IMPORT_LIBRARY_NAME}"
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FASTLOESS_CMAKE_OPTIONS "-DFASTLOESS_ARCH=${VCPKG_TARGET_ARCHITECTURE}")
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
