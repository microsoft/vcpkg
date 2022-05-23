vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            septag/dmon
    REF             59fac713a168b6c9fd08db48da49f7bd50fd9d37
    SHA512          61fa6a0e243be456d3b59d20e18183392d106983dc9f1b0a7290b54fefa964d4eeba4bacd92cd5310b6f3da2dac232fd043c529c51fe3e6cccbfb9422dd31311
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
