# CrashCatch is a header-only library — no compilation required.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keithpotz/CrashCatch
    REF "v${VERSION}"
    SHA512 ba3f431b1c1da9f8ead4038ff8073df3010394ce84a6976ba6b9e9f50842a3aacb367b443a92fef75317ee49cf08384a39d76b944bf1e2735d3e2a3647c63f01
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME CrashCatch
    CONFIG_PATH lib/cmake/CrashCatch
)

# Header-only: no debug artifacts
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
    COPYONLY
)
