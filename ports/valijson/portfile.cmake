vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF "v${VERSION}"
    SHA512 4e1bcbb006e090c58e209acb46045548b6ba92162ae8061f6ecc74eaebf5b26a8457192fc23e1efccb00970cc590b87e724bab29b0bc34d5504da2ee24bfa795
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # headers only

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dvalijson_BUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()


vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/valijson")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
