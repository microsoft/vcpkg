if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(FASTLOWESS_ARCH x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(FASTLOWESS_ARCH arm64)
else()
    message(
        FATAL_ERROR
        "fastlowess does not support ${VCPKG_TARGET_ARCHITECTURE}."
    )
endif()
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
    set(FASTLOWESS_BINARY_NAME "fastlowess-win32-${FASTLOWESS_ARCH}.dll")
    if(FASTLOWESS_ARCH STREQUAL "x64")
        set(FASTLOWESS_BINARY_SHA512
            f497eaa4e5fd9b7dc480022416a8182cd57f9ac2cf1e05d8d18ab636e9b96a3cb3150f762ed132cd49aa810dd21e2b23086a13e33f5ca3ba21883b4a1a15ff75
        )
    else()
        set(FASTLOWESS_BINARY_SHA512
            fdf9b4d7851e7dc599a6bf6141e347fa2f43b525f0d05e9ca66e7527fc1e84bbcc4e0462e44b880c1717e442c2e67124494bfd1f807e538ba9bae174cd38b657
        )
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_TRIPLET MATCHES "musl")
        set(FASTLOWESS_LIBC_SUFFIX "-musl")
    endif()
    set(FASTLOWESS_BINARY_NAME
        "libfastlowess-linux-${FASTLOWESS_ARCH}${FASTLOWESS_LIBC_SUFFIX}.so"
    )
    if(
        FASTLOWESS_ARCH STREQUAL "x64"
        AND FASTLOWESS_LIBC_SUFFIX STREQUAL "-musl"
    )
        set(FASTLOWESS_BINARY_SHA512
            fd39485553b73de74d8330aeb282e83ccaffcfb2e1a842218cffeddb465ef2934601a6b1584b7522dc49da573ab75265e419cd4446ac660fa81c64cd60bd1b72
        )
    elseif(
        FASTLOWESS_ARCH STREQUAL "arm64"
        AND FASTLOWESS_LIBC_SUFFIX STREQUAL "-musl"
    )
        set(FASTLOWESS_BINARY_SHA512
            00a8c78bdfbe4db300ae7dc08966c1e81f74c7b13716515a8fe0dd658bf5939fbb692c7ec0aa7f3761615c73aff4edbc8457721745da3b1876d77b349b092a7b
        )
    elseif(FASTLOWESS_ARCH STREQUAL "x64")
        set(FASTLOWESS_BINARY_SHA512
            10df22a7a417ca4c66aaa026cfa07832fee48501ab523778a803d840683830e73b0c1f52afb2b423b5afc1badef24a6d9cd795bc0e30ebd3e5cae5a361e658e4
        )
    else()
        set(FASTLOWESS_BINARY_SHA512
            a17f2d0845c30b171d3bc2a4719ed6b327965c7208cf42ccf1602a5d17a018fc539e50b9e2aec01a57bb1aac1df5da54045336988645be403463ab2a9ea1acf6
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    set(FASTLOWESS_BINARY_NAME "libfastlowess-macos-${FASTLOWESS_ARCH}.dylib")
    if(FASTLOWESS_ARCH STREQUAL "x64")
        set(FASTLOWESS_BINARY_SHA512
            7d256f084cf096cdffce786397fb7295be8a2972535129ee42016c050aacd50d7965108cbab73df2a2190dc2adc737b7b864c21061742fb119069f9734815683
        )
    else()
        set(FASTLOWESS_BINARY_SHA512
            79191477309f931e93a307c0c0a76472c9317486ac3da009763c165cfa4abe24c1c4b07dd932e6cde9ed7585689bc345e57538d52e70ecf3506ca7d0526acf95
        )
    endif()
else()
    message(FATAL_ERROR "fastlowess does not support this target platform.")
endif()

vcpkg_download_distfile(
    FASTLOWESS_BINARY
    URLS "https://github.com/thisisamirv/lowess-project/releases/download/v${VERSION}/${FASTLOWESS_BINARY_NAME}"
    FILENAME "fastlowess-v${VERSION}/${FASTLOWESS_BINARY_NAME}"
    SHA512 "${FASTLOWESS_BINARY_SHA512}"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/lowess-project
    REF "v${VERSION}"
    SHA512 23fcff5a20a4f8182b5b9015449e59aeedefc806be4646934a203264cc3336e207ef2f7fbf694b72210fbfb52f1be2581a12c0399821d3e49209202c653657c8
)
set(FASTLOWESS_CMAKE_OPTIONS
    "-DFASTLOWESS_SOURCE_DIR=${SOURCE_PATH}"
    "-DFASTLOWESS_BINARY=${FASTLOWESS_BINARY}"
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FASTLOWESS_CMAKE_OPTIONS "-DFASTLOWESS_ARCH=${FASTLOWESS_ARCH}")
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
    COMMENT "The prebuilt native library statically links Rust dependencies. Dependency license manifests and notices can be obtained by checking out lowess-project v${VERSION} and running cargo-about against bindings/cpp/Cargo.toml. This release does not publish the original binary build's Cargo.lock; exact dependency-version provenance is therefore not provided by this port."
)
file(
    INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
