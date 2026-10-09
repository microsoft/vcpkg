vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
    if(VCPKG_TARGET_IS_MINGW)
        message(
            FATAL_ERROR
            "fastlowess prebuilt Windows archives require the MSVC ABI."
        )
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_PLATFORM windows-x64-msvc)
        set(FASTLOWESS_BINARY_NAME fastlowess-win32-x64.dll)
        set(FASTLOWESS_ARCHIVE_SHA512
            433c5f2afb6792d7633e8c74f17569876d755f13f68cb912b17578447085e8d5a5e90cde0b9817b8056a9d092b904082de63f3d7e91506a90d516fc0f2f287e2
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_PLATFORM windows-arm64)
        set(FASTLOWESS_BINARY_NAME fastlowess-win32-arm64.dll)
        set(FASTLOWESS_ARCHIVE_SHA512
            ddd07612614521b76a019ae8b926416cd57d2a7338d462128954ad5f1b4ae4d1951dcdbed9331c22e7204b5a36567d2373bedf16d149f64bc9172b0a14ce58c4
        )
    else()
        message(
            FATAL_ERROR
            "fastlowess does not support Windows architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
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
    set(
        FASTLOWESS_BINARY_NAME
        "libfastlowess-linux-${FASTLOWESS_ARCH}.so"
    )
    set(FASTLOWESS_LIBRARY_DIR lib)
    if(FASTLOWESS_ARCH STREQUAL "x64")
        set(FASTLOWESS_ARCHIVE_SHA512
            89176a4f0364746b5bc8fd463bacaf172a21eb03047b56a8dbf61d1a0d5f4243b0cdae7bde6136ceec71afa0817b92e532bd6edf74bda26f501f6bce655de3ad
        )
    else()
        set(FASTLOWESS_ARCHIVE_SHA512
            f9cbffbbae2c21d901d7df095f18de0a4a3fd610487b767ccb61ea31a663ee7e06a789412b1b3a1c645b58f0c9fe92682169b0240ad496dc8aa296df5d4230d8
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOWESS_ARCH x64)
        set(FASTLOWESS_ARCHIVE_SHA512
            b354096320f3ad64c59d6c64d15acf5d160e9bba469bd5648db3ebc0c374d93446ded55f18751442e9157f3ca51ed72acdb126628421846ae7a4950e67237ec0
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOWESS_ARCH arm64)
        set(FASTLOWESS_ARCHIVE_SHA512
            aeb4f5dab984af559d7b7772e8c9f270faa9d949b04f3e85b2c3d0aa9f11642333473e098f7cf46335fe9d5190a450863942eb96cc39af7158f08f618aa2b789
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
    SHA512 275ab96c8a7dd7498025b9c6602135c243f5860b833a12147f54fb95ad3beaf82c10ddd39aeb82c2d5c9018375753e1046b60eda0a7a5776dc42bbe0de4397a6
)
set(FASTLOWESS_CMAKE_OPTIONS
    "-DFASTLOWESS_VERSION=${VERSION}"
    "-DFASTLOWESS_PACKAGE_DIR=${FASTLOWESS_PACKAGE_DIR}"
    "-DFASTLOWESS_BINARY_NAME=${FASTLOWESS_BINARY_NAME}"
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FASTLOWESS_CMAKE_OPTIONS "-DFASTLOWESS_ARCH=${VCPKG_TARGET_ARCHITECTURE}")
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
