vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO teslamotors/fixed-containers
    REF 1ad10a6ca835611124f54a1d8ed04bcf7ab53da4
    SHA512 71b7ea86ed45bac39c2f22c572f84d3a9862aab350eeef5d72c6061d42c10bf7fad26cafc6c6b991cdf3ac758b23c29fd8d3414f1b2af7c65058bc31d000b49b
    HEAD_REF main
    PATCHES add-install-configuration.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

file(COPY "${CMAKE_CURRENT_LIST_DIR}/fixed_containersConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTS=OFF
    -DFIXED_CONTAINERS_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME fixed_containers CONFIG_PATH lib/cmake/fixed_containers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
