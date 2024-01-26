set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v${VERSION}"
    SHA512 9215535aed1d26455dbfbcfdcd8f029fe53fe78a0a7bbe6fa30e32e42a9904d40909db8fb08e9e7b35a037edc5137b14d6c66855122965fedac8efc73588bf72
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

