if(NOT VCPKG_HOST_IS_WINDOWS)
    message(FATAL_ERROR "fastlowess currently requires a Windows build host.")
endif()
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

find_program(
    FASTLOWESS_CARGO
    cargo
    HINTS "$ENV{USERPROFILE}/.cargo/bin"
    REQUIRED
)
find_program(
    FASTLOWESS_RUSTC
    rustc
    HINTS "$ENV{USERPROFILE}/.cargo/bin"
    REQUIRED
)
execute_process(
    COMMAND "${FASTLOWESS_RUSTC}" --version
    OUTPUT_VARIABLE rust_version
    COMMAND_ERROR_IS_FATAL ANY
)
string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" rust_version "${rust_version}")
if(rust_version VERSION_LESS "1.89.0")
    message(
        FATAL_ERROR
        "fastlowess requires Rust 1.89 or newer. Run rustup update stable."
    )
endif()
get_filename_component(rust_bin "${FASTLOWESS_CARGO}" DIRECTORY)
vcpkg_add_to_path("${rust_bin}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/lowess-project
    REF "v${VERSION}"
    SHA512 23fcff5a20a4f8182b5b9015449e59aeedefc806be4646934a203264cc3336e207ef2f7fbf694b72210fbfb52f1be2581a12c0399821d3e49209202c653657c8
)
file(COPY "${CURRENT_PORT_DIR}/Cargo.lock" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS
        "-DFASTLOWESS_SOURCE_DIR=${SOURCE_PATH}"
        "-DFASTLOWESS_CARGO=${FASTLOWESS_CARGO}"
        "-DFASTLOWESS_RUSTC=${FASTLOWESS_RUSTC}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(
    REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(
    INSTALL "${CURRENT_PORT_DIR}/Cargo.lock"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-APACHE"
    COMMENT "The native library statically links Rust dependencies. Their exact versions are recorded in the installed Cargo.lock. To obtain their manifests and license files, check out lowess-project v${VERSION}, copy this lockfile to its root, and run cargo fetch --locked. Dependency sources and license files are then available in Cargo's registry source directory."
)
file(
    INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
