vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/zopfli
    REF bd64b2f0553d4f1ef4e6627647c5d9fc8c71ffc0 # zopfli-1.0.3
    SHA512 3c99a4cdf3b2f0b619944bf2173ded8e10a89271fc4b2c713378b85d976a8580d15a473d5b0e6229f2911908fb1cc7397e516d618e61831c3becd65623214d94
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

configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
