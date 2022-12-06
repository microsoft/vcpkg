vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/ShaderWriter
    REF v${VERSION}
    HEAD_REF development
    SHA512 d87f5e2641b064b6d6c53c2af86ed3c133f76a408728f4ad4fbc122d4392b4da21fea3faa0b2f58391e348f23c972f3c0196386c5c8c66800500da99d4522f70
)

vcpkg_from_github(OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 3bea3c21f76f49cd3730e555b32e9d401b542526
    HEAD_REF master
    SHA512 28c13672abe7a29e4c11192f3bbc10fd09d30f0719911370d7a1d70a534d41679feffafaad4ac1c1dd32403541ecf44b5021a1b8052418190dc040ed833ff15b
)

file(REMOVE_RECURSE "${SOURCE_PATH}/CMake")
file(COPY "${CMAKE_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/CMake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
        -DSDW_GENERATE_SOURCE=OFF
        -DSDW_BUILD_VULKAN_LAYER=OFF
        -DSDW_BUILD_TESTS=OFF
        -DSDW_BUILD_STATIC_SDW=${BUILD_STATIC}
        -DSDW_BUILD_STATIC_SDAST=${BUILD_STATIC}
        -DSDW_UNITY_BUILD=ON
)

vcpkg_copy_pdbs()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ShaderWriter CONFIG_PATH lib/cmake/shaderwriter)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
