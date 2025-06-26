vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO royjacobson/ser20
    REF "v${VERSION}"
    SHA512 3a9b796151d6fe48bf322758359ed6e39fa0025ada8fae0ca46177a986eb37c191fc014c5ad4776260aae4ed91c4d807a1b1175b7e13126a02fe7752314e3530
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_SANDBOX=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

# Only run config fixup for release, not debug
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ser20
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    ${SOURCE_PATH}/LICENSE
    ${SOURCE_PATH}/include/ser20/external/LICENSE
    ${SOURCE_PATH}/include/ser20/external/rapidjson/LICENSE
    ${SOURCE_PATH}/include/ser20/external/rapidxml/license.txt
)
