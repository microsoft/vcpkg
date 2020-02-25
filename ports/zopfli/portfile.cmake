include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/zopfli
    REF ef109ddf164911cf1e5612e90b4a619839a1e3ca
    SHA512 9067d14c3ca7f5f07a0c4913ae1804128cf928770359618eab3c655ccbfa7260a11ec1db871a7e5be7d92098c2dda5a55b948eb779c9c64647bddfd1e9ace1f5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DZOPFLI_BUILD_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

# Install tools
file(COPY ${CURRENT_PACKAGES_DIR}/bin/zopfli${EXECUTABLE_SUFFIX}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${CURRENT_PACKAGES_DIR}/bin/zopflipng${EXECUTABLE_SUFFIX}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/bin/zopfli${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/zopflipng${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/zopfli${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/zopflipng${EXECUTABLE_SUFFIX}
    )
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Zopfli)

# vcpkg_fixup_cmake_targets can not handles this on UNIX currently.
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR
   VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-debug.cmake
        "\"\${_IMPORT_PREFIX}/debug/bin/zopfli\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopfli\""
    )
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-debug.cmake
        "\"\${_IMPORT_PREFIX}/debug/bin/zopflipng\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopflipng\""
    )
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-release.cmake
        "\"\${_IMPORT_PREFIX}/bin/zopfli\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopfli\""
    )
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-release.cmake
        "\"\${_IMPORT_PREFIX}/bin/zopflipng\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopflipng\""
    )
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
