set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO al-sabr/FlashRuntimeExtensions
    REF v2.4
    SHA512 16db340a9c8d868c64b9771e3ac9a20e775fa145f36158e798733b788fd99d1ac101bfae93b8f88b0e5a0a530e0261c1fbdf7d367031dd3108c14ee00a106c10
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")