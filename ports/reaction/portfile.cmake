vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lumia431/reaction
    REF b06294a1092f17f6dae94af78ec0be6c29c83f90
    SHA512 26c0537c8734b7cfb14195a4cca8f63ca93499cc367ba601679a60021a9fb7cf74f0411432f9f82d019f135fc9113cd6c72b41fa42b16999f4c333f7f2ccc510
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/reaction)

file(INSTALL "${SOURCE_PATH}/include/reaction.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
