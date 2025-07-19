vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arun11299/cpp-subprocess
    REF "v${VERSION}"
    SHA512 5be80a4a181f8534b6e2b36a2b192b77edd70b527ef881195ef02e915a1f78c894a804029a82f2f927c5194baef71a4f3184c124d42a6dd3c53cdc694410a576
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSUBPROCESS_TESTS=OFF
        -DSUBPROCESS_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MIT")
