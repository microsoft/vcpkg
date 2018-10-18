include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/brotli
    REF v1.0.2
    SHA512 b3ec98159e63b4169dea3e958d60d89247dc1c0f78aab27bfffb2ece659fa024df990d410aa15c12b2082d42e3785e32ec248dce2b116c7f34e98bb6337f9fc9
    HEAD_REF master
    PATCHES install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBROTLI_DISABLE_TESTS=ON
)

vcpkg_install_cmake()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/brotli)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-brotli TARGET_PATH share/unofficial-brotli)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-brotli)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brotli RENAME copyright)

vcpkg_copy_pdbs()
