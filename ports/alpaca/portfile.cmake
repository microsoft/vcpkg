#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/alpaca
    REF v${VERSION}
    SHA512 0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DALPACA_BUILD_TESTS=OFF
        -DALPACA_BUILD_BENCHMARKS=OFF
        -DALPACA_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()

#Copy missing details/types folder from source path
file(COPY "${SOURCE_PATH}/include/alpaca/detail/types" DESTINATION "${CURRENT_PACKAGES_DIR}/include/alpaca/detail/")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/alpaca PACKAGE_NAME alpaca)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
