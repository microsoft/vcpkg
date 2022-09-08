vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/alpaca
    REF v0.2.0
    SHA512 0ac2c1c4f8e0534319bf852bac3852ee3674db7b1a9eda30462821ec4c9ddeeb6ceff09ef5f16eed9131af6c357a09f2cb909a12ea2f135ca7d496d90ff1865d
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
