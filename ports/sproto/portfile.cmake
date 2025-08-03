
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cloudwu/sproto
    REF 63df1ad8be4a7b295d389afaca7019e86f70d39c
    SHA512 5613a04e6197b6fa00828f457aeee0270a7f4d300df609d62e405123f3623516c5761bd2c6b0b8e21be12aa30ca3288ae6307121bf8461535ad8c3efe9a750a2
    HEAD_REF master
)

# Copy our CMakeLists.txt and config template to source
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/sproto-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()

vcpkg_cmake_install()

# Remove debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Note: sproto creates static libraries, so lib directories should be kept

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_cmake_config_fixup(CONFIG_PATH share/sproto)