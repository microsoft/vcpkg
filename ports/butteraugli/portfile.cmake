vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/butteraugli
    REF 71b18b636b9c7d1ae0c1d3730b85b3c127eb4511
    SHA512 2e73f8ad8953307eea956ed8bd828e110419d6d9f8a42685d225953d3a8017a79d0701bde0282459dc51198e75a99dcd99dd3c4e7ef065736c512a7b11ea0fdf
    HEAD_REF master
    PATCHES
        missing_header.patch
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

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
