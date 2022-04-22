vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libhydrogen
    REF 01c32862f6f6e864c113efc3f0142e05ea3531fe #2021-12-02
    SHA512 016181db4573a1ab31547fbfb51e19fa09e4ee4e0e788434a7654921956a02547b55eda14ccfea98425f4f615fb90e0534c5e1010d5320c1958b65b0489a2931 
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/hydrogen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
