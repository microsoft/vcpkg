include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v8.0.1
    SHA512 029b32bc275cecb95e5dc451dcf9efdb4f5b24f4ff6c6358960f6b4b45237aee12d0c2aee7dfe8e08ac1c8e9a65412f6d89578a84538b2fb4fc8c35409282fe3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC++_INSTALL=ON
        -DREPROC_INSTALL=ON
)

vcpkg_install_cmake()

file(GLOB REPROC_CMAKE_FILES ${CURRENT_PACKAGES_DIR}/lib/cmake/reproc++/*)
file(INSTALL ${REPROC_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc++)
file(INSTALL ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/reproc++/reproc++-targets-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc++)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/reproc)

# Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/reproc/LICENSE ${CURRENT_PACKAGES_DIR}/share/reproc/copyright)
