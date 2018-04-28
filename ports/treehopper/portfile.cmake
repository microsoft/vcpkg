include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO treehopper-electronics/treehopper-sdk
    REF 1.11.2
    SHA512 6bf8bf175d1488ebfb44d9949a07c1a6754dff58ba7ea1ee745ef25eba087016eea978f025f5f73429a13b9e0e45cc074f1e1cdb86b2f76867d8ff9c086811cd
    HEAD_REF master)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/C++/API/
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/C++/API/inc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Treehopper/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/treehopper RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)