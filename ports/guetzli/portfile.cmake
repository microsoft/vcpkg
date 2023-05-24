vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/guetzli
    REF 214f2bb42abf5a577c079d00add5d6cc470620d3 # accessed on 2020-09-14
    SHA512 841cb14df4d27d3227e0ef8ecff6bd8a222d791abfc8fb593bf68996ed8861a9cc483f1a9b140023a247a5b1a350197601ca75a990507aaafa1b2dd03f8577d0
    HEAD_REF master
    PATCHES butteraugli.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/guetzli")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/guetzli" RENAME copyright)
