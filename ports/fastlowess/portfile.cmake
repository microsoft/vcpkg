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
            106d9c85a282d9522e0e173e9b0fae0d0c1f9f30a6f51b527d774670aefc557093dd8af31244d887f61b77711888bef4d407afaf6b601cce00c6aef9a9df2be4
        )
        set(FASTLOWESS_DEBUG_ARCHIVE_SHA512
            6aa72b47f65d73cfd1907decd0e1db9a2b9bf57d43d43672656b27d384252e51ef2c493ccdf9ae67710981f7e3e78c9e6325af6fb4b1e250dc668077ffe97c8e
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_PLATFORM windows-arm64)
        set(FASTLOWESS_DEBUG_PLATFORM windows-arm64-debug)
        set(FASTLOWESS_BINARY_NAME fastlowess-win32-arm64.dll)
        set(FASTLOWESS_DEBUG_BINARY_NAME fastlowess-win32-arm64-debug.dll)
        set(FASTLOWESS_ARCHIVE_SHA512
            81892e805049ac73d0b55ce0e57707451b9ee35657e78f702655306a5f8c536741c49f68736604be230800cf755a1ce8d0941903a2e21e947c7d56108c70fdd9
        )
        set(FASTLOWESS_DEBUG_ARCHIVE_SHA512
            44f702a273714f28f3b3a146740c134b3ccf20063b8e66d1b11dd04a468f31c0fec7006c1366aea25eb81cb59316cb03751211eb5081609c3c3d1e488ec4720c
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
            9aa705ef485be938834db4202d8e4b0397e7c10869f12440dfbfd53ec2d6363f9574bfa886fb839dd0068aed95b1f8c49d54d3f37082f063c8fd4e2d2226825f
        )
    else()
        set(FASTLOWESS_ARCHIVE_SHA512
            7f43f2919cad8b95e93648c5a99420a0f85bb9897168743d40d88e124e6d55bcb5dd29179f05fa555e38407dfd93aff5f3367e5df9264dd6002d084acb2fd999
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_ARCH x64)
        set(FASTLOWESS_ARCHIVE_SHA512
            030dbf0788f7f9c513691c961f88845a815becfada5b7165d9d66eb1af9d9891c5f5f0114b33a19583e05ca002876a52eaf04868b20b39c0b3e03a7209fdde67
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_ARCH arm64)
        set(FASTLOWESS_ARCHIVE_SHA512
            3f601ea4f86627976980bd4d157f9f2e2c71645735dbfab1be6d848acf499c5fc11cf515b71decbb9d5bb68bfecb4683c5dc5fdb7305836488a2be1e55520d63
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
    SHA512 0f7f00a6faa5af9d39d36254e8d9bfc18088a3602228edf44bbe8f3267c4323c5174eba42dafd66a20957e5ada6474b409f0493f85119261edbd1c9ab54be60f
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
