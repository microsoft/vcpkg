vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/fswatch
    REF             045f44c1c410f1f3c425e10d59c786a86401ccbd
    SHA512          7333a33066b7dbf50304b405921b93229941455f70902e14162e3cc47e6822fa8cfa0ccce19bfebea73867f648fcdaeaab32ce48df9e01f4ef4149dac09b4dcb
    HEAD_REF        multi-os-ci
    PATCHES
        remove-intrin-h-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_FSWATCH=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
