vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rjahanbakhshi/boost.taar
    REF 7011370b2c0176a80da23e6600dfa3e4474ea312
    SHA512 f1aacfa5751e2337886683d3048f414a2bc443d3e4020d50e0c539ea72318d4c67cc31f01a1ec0e6bf884aa0900842ada906c1f46bcaec7a578b8e4fe8c438de
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOOST_TAAR_BUILD_TESTS=OFF
        -DBOOST_TAAR_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME boost-taar CONFIG_PATH share/cmake/boost-taar)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
