vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realm/realm-cpp
    REF "v${VERSION}"
    SHA512 "cf975741b5a4a68a40845c53d8584d871acff03c7a212e71a67799801979e0514de2a449aa5d78137f2d7f42e113c5df7c97e9f8c5fb6371e95c46f29ab2b246"
    HEAD_REF "main"
)

if(NOT VCPKG_BUILD_TYPE)
    set(DISABLE_ALIGNED_STORAGE 1)
else()
    set(DISABLE_ALIGNED_STORAGE 0)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
    -DREALM_DISABLE_ALIGNED_STORAGE=${DISABLE_ALIGNED_STORAGE}
    -DREALM_CPP_NO_TESTS=ON
    -DREALM_ENABLE_EXPERIMENTAL=ON
    -DREALMCXX_VERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
