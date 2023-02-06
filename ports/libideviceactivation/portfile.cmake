vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libideviceactivation
    REF be6ffe8788cbb633bff0526f4e7a69625f0cdad6 # v1.1.1-20220824
    SHA512 52331d7772526efec58d8b85924bcda1b8ba12977dc74685e2b6b5ccd87e5ca2a7021e74256d3ffc07ce646dbbf73a8bd1f3843ec1c98feafef3d1bfbdc824ab
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES ideviceactivation AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
