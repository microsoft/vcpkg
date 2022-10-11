vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/liblinear
    REF 60f1adf6f35d6f3e031c334b33dfe8399d6f8a9d #v243
    SHA512 0f88f8dd768313d0a9b3bb82e7b878d7173ea43ef609e993dc79e94398897373faf2688249b17111e2b6e06e78e26a50570a1b746dc4e73fb7416ccc24936c66
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
