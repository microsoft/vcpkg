vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF 4d2f26ee8ff2c96c6c93e7e2b7f5162027f2482d # v1.0+1
    SHA512 69a27ae87eaa5523905e80fd1028208f2862cdd76c467e8d12dc1cca388965edb7615ae102bc1af13d824ad681eea17f69a42e790755f88ad57cae11b4268683
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCROW_BUILD_EXAMPLES=OFF
        -DCROW_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Crow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
