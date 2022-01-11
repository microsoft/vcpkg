vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO injae/serdepp
    REF v0.1.3.1
    SHA512 4102f87748010b2369bbda0afbde2aa567cf33098d62e0b71130c1203b8cfa583d29e4ac486aa32dab3ce7960252095cb33fb9517c08d25703779fdebf6218f4
    HEAD_REF main
)

find_package(Git REQUIRED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/serdepp)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/cmake
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/lib/cmake
)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/serdepp RENAME copyright)
