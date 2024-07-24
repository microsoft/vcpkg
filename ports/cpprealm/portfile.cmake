vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realm/realm-cpp
    REF "v${VERSION}"
    SHA512 "d880daea7bceb3143052cae9d8883b448162484adacc566cca5315ac096964d0c79c421b25a76d5c2efbd8c3294dfb5acd3dd7314a6c154163e7d141b9eb2e51"
    HEAD_REF "main")

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
