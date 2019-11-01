include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libhydrogen
    REF 46f083ed1370f4f1063f412b443f5a7704676f27
    SHA512 2408ba8ba365751cf4e4e52191f8a94fe00befcb1b6c741af73b3eeebe6e02aa191d9ad021b5eda555c2eeb9c9f39ab7d89a94fb7e0e2896bf4a015d2b8e2995
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/hydrogen TARGET_PATH share/hydrogen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME hydrogen)
