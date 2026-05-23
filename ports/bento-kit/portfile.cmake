string(REGEX MATCH "^([0-9]+\\.[0-9]+)" _ "${VERSION}")
set(BENTO_KIT_RELEASE_REF "release_${CMAKE_MATCH_1}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imcooder/bento-kit-cpp
    REF "${BENTO_KIT_RELEASE_REF}"
    SHA512 81f1900ce9e2fb691baf47a2eed1f5b65b9a16b2df0e66be41b97eadb7b6b0c9ef274d33ad4a29e878a8d495cfb2703c7e110ca850c5bfc1ef6dd15f0c3afce2
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBENTO_KIT_BUILD_TESTS=OFF
        -DBENTO_KIT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "${CMAKE_INSTALL_LIBDIR}/cmake/bento-kit")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
