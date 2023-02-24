# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ricab/scope_guard
    REF "v${VERSION}"
    SHA512 48d75658c9f2c8770b6379f968ee498bc90b5e5e14f26c6e89ffd7d50a8230260db262da27fe4aa3c6c1b302fe73d9aa9a7c853e01adcf5a6313e3462d3a8407
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/scope_guard.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
