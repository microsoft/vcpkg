vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lumia431/reaction
    REF "${VERSION}"
    SHA512 45c4065c0db3a0f08484b73b3b4ce24f6c7816a8c2ffbfefaf59f92c7c44efccecd80faf649b5076ca37dce6a9fe52203cb5d6e95b933a2977934682f94c5e8e
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

