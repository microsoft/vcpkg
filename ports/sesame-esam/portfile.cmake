# vcpkg overlay port for the SESAME C++ SDK.
#
# Use it today with:
#   vcpkg install sesame-esam --overlay-ports=<repo>/cpp/ports
# then in your project: find_package(sesame CONFIG REQUIRED)
#                       target_link_libraries(app PRIVATE sesame::sesame)
#
# SHA512 is pinned to the cpp-v0.1.1 tag's source archive. Update REF + SHA512
# (run `vcpkg install` once to have it print the correct hash) when bumping.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bokelleher/sesame-sdk
    REF cpp-v0.1.1
    SHA512 b93b286b17aa6f3705747935bedce150b5ab2b0d5df91cd5cbd5a49e5c03c1d0e6691bc5003ba95673b7bbcd63af983238be4b852dfdd39c0b5398d3315f84b9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DSESAME_BUILD_TESTS=OFF
        -DSESAME_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sesame CONFIG_PATH lib/cmake/sesame)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/LICENSE-APACHE")
