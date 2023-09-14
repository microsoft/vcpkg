#header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO victorfisac/Physac
    REF "${VERSION}"
    SHA512 c539ee73d6f456e592d4a92cc5707278476632626b0fa0edfe6396cd4460fe0c2669843f4df3a22a132664d1981d261601061cca76ad1e4b63510a901fc3987b
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/physac.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")
