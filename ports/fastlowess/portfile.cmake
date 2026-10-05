if(NOT VCPKG_HOST_IS_WINDOWS)
    message(FATAL_ERROR "fastlowess currently requires a Windows build host.")
endif()
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)

vcpkg_download_distfile(
    FASTLOWESS_BINARY
    URLS "https://github.com/thisisamirv/lowess-project/releases/download/v${VERSION}/fastlowess-win32-x64.dll"
    FILENAME "fastlowess-v${VERSION}-win32-x64/fastlowess-win32-x64.dll"
    SHA512 f497eaa4e5fd9b7dc480022416a8182cd57f9ac2cf1e05d8d18ab636e9b96a3cb3150f762ed132cd49aa810dd21e2b23086a13e33f5ca3ba21883b4a1a15ff75
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/lowess-project
    REF "v${VERSION}"
    SHA512 23fcff5a20a4f8182b5b9015449e59aeedefc806be4646934a203264cc3336e207ef2f7fbf694b72210fbfb52f1be2581a12c0399821d3e49209202c653657c8
)
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS
        "-DFASTLOWESS_SOURCE_DIR=${SOURCE_PATH}"
        "-DFASTLOWESS_BINARY=${FASTLOWESS_BINARY}"
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
