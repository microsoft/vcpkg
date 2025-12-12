set(VCPKG_BUILD_TYPE release)  # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MistEO/meojson
    REF v${VERSION}
    SHA512 5f30b52e3e9619bac7e0f3b40cd6ce3c4330538d63a221cdbf4f20a29e282774cf26ba4fc9fefa6f8ab9dcbe1358b60cbd39440d1ab97b43d663de21db715dce
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SAMPLE=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/meojson)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
