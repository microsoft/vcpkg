vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/liblinear
    REF v${VERSION}
    SHA512 5c51f614f9dfe6e0338b0c34d4b3b7a8941425db5e0b902c3308cca4cc23407e64ed4679f7ec70c1d0e500e4a4139ca86af2d02c28efb5b3b5f9d323f403f513
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
        -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT DISABLE_INSTALL_TOOLS)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/liblinear")
endif()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
