if (EXISTS ${CURRENT_INSTALLED_DIR}/share/lodepng-c/copyright)
    message(FATAL_ERROR "${PORT} conflict with lodepng-c, please remove lodepng-c before install ${PORT}.")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lvandeve/lodepng
    REF e34ac04553e51a6982ae234d98ce6b76dd57a6a1
    SHA512 ab79fb2c6403e5d7bdf0b94a3f93f6513889eda8e6b74fb2b569fbc6f95fb79474654818cb0e71eff88214ca7c42ebd7c95f734a2faa77259fe06bfddcb6967a
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
        -DDISABLE_INSTALL_TOOLS=ON
        -DDDISABLE_INSTALL_EXAMPLES=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Moves all .cmake files from /debug/share/lodepng/ to /share/lodepng/
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/lodepng.h" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
