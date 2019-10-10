include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v9.0.0
    SHA512 c9ab8c459f4cdf2b740edd461eefa2972a068078999ab97efff4473f1fae4dd774d00ea56cb33bdf883f78eb8d8b73aa721d35dd77e016b047cf4c9dadfee72b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
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
