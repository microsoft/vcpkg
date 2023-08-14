#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 9db6276dce851dc2b6807fc81bffbec2e27acd0b
    SHA512 da26905b2665e952c06a42f1b56e7cb6e335cccb592d7dac5e59a11bbf2b10e5d532649383d2feb2313432c9be5068a2cd57b368a309f65899cbff61e866fc10
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install natvis files
file(INSTALL "${SOURCE_PATH}/natvis/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/natvis")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")