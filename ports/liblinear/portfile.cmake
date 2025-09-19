vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/liblinear
    REF v${VERSION}
    SHA512 fd49baf145c047b31ecbded7c02cbb3501d5c3854c53b435dadd1240e4803759215826b43fa62d36001de9f62a261c42e38b2b5647074c574eedb1eb96112b37
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
