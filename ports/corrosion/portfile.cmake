set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v${VERSION}"
    SHA512 9ad1a8645fee3a3f03b0daec8699275f7f3f2251c0efde4af97e20f1c55972151401e0593a6a7cb65ad36b69d4c0d8b45c9a35375111c5ac38c108df5e0522b5
    HEAD_REF master
)

find_program(CARGO cargo PATHS "$ENV{HOME}/.cargo/bin/")
if (CARGO STREQUAL "CARGO-NOTFOUND")
    message("Could not find cargo, trying to install via https://rustup.rs/.")
    execute_process(COMMAND bash "-c" "curl -sSf https://sh.rustup.rs | sh -s -- -y")
endif()

# Redo with the install process and just ignore the warnings?
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Corrosion)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

