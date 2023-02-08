vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/zopfli
    REF bd64b2f0553d4f1ef4e6627647c5d9fc8c71ffc0 # zopfli-1.0.3
    SHA512 3c99a4cdf3b2f0b619944bf2173ded8e10a89271fc4b2c713378b85d976a8580d15a473d5b0e6229f2911908fb1cc7397e516d618e61831c3becd65623214d94
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOPFLI_BUILD_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Install tools
file(COPY "${CURRENT_PACKAGES_DIR}/bin/zopfli${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY "${CURRENT_PACKAGES_DIR}/bin/zopflipng${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/bin/zopfli${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/bin/zopflipng${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/debug/bin/zopfli${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    "${CURRENT_PACKAGES_DIR}/debug/bin/zopflipng${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Zopfli")

# vcpkg_cmake_config_fixup can not handles this on UNIX currently.
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR
   VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-debug.cmake"
            "\"\${_IMPORT_PREFIX}/debug/bin/zopfli\""
            "\"\${_IMPORT_PREFIX}/tools/zopfli/zopfli\""
        )
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-debug.cmake"
            "\"\${_IMPORT_PREFIX}/debug/bin/zopflipng\""
            "\"\${_IMPORT_PREFIX}/tools/zopfli/zopflipng\""
        )
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-release.cmake"
        "\"\${_IMPORT_PREFIX}/bin/zopfli\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopfli\""
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zopfli/ZopfliConfig-release.cmake"
        "\"\${_IMPORT_PREFIX}/bin/zopflipng\""
        "\"\${_IMPORT_PREFIX}/tools/zopfli/zopflipng\""
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
