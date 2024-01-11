vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-source-patterns/nanojsonc
        REF "${VERSION}"
        SHA512 65ee05d9df7e44702fce22c458aa53762cfe00d3fdf1ce93a034849c56ddc0dbb4bb86e20c175b5d9a2ce43a97c82c99f042c122abcfe44dfb5d9d88e8b32e39
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DBUILD_TESTS=OFF)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # Install License
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # Install Usage
