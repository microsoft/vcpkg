include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/memory
    REF 9673ac1d0405dd0a9c9a03058e5554df61b4cb67
    SHA512 a3d7066ae14eba1e7b1092db13ae66cce69114bbf2719182adb7b23f4bea128636fb9ac442c82952d3ef7fb8e8c1a4fc497b49ea28be02edd3a69465438b1cf0
    HEAD_REF master
    PATCHES
        export-all-symbols.patch
        fix-install-includedir.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH COMP_SOURCE_PATH
    REPO foonathan/compatibility
    REF cd142129e30f5b3e6c6d96310daf94242c0b03bf
    SHA512 1d144f82ec46dcc546ee292846330d39536a3145e5a5d8065bda545f55699aeb9a4ef7dea5e5f684ce2327fad210488fe6bb4ba7f84ceac867ac1c72b90c6d69
    HEAD_REF master
)

file(COPY ${COMP_SOURCE_PATH}/comp_base.cmake DESTINATION ${SOURCE_PATH}/cmake/comp)

if("tool" IN_LIST FEATURES)
    set(FOONATHAN_MEMORY_BUILD_TOOLS ON)
else()
    set(FOONATHAN_MEMORY_BUILD_TOOLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF
        -DFOONATHAN_MEMORY_BUILD_TESTS=OFF
        -DFOONATHAN_MEMORY_BUILD_TOOLS=${FOONATHAN_MEMORY_BUILD_TOOLS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/foonathan_memory)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/LICENSE
    ${CURRENT_PACKAGES_DIR}/README.md
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
