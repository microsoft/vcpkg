include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF aba3ce528ff48c4ce84365d2c395b9f0a7c1824d
    SHA512 3305c868c814a9c8a22e0e4c1229bd00c302cb56a3cde416c37a4d4eb2f7e0ca55165ca768da903aedc4e2267f77dae8bc8aec70fb3035b4b2ff45aae0c467aa
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
