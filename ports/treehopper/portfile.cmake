include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO treehopper-electronics/treehopper-sdk
    REF 1.11.1
    SHA512 cd45f8ce403378ec717f6ae4a1727de50b3844789cd767b0013ffbbe6bfe30bc3f7b712e9ba405582d9d83c456ddf8fd87f993bb26778a921db99e7caf0e6862
    HEAD_REF master)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/C++/
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/C++/API/Treehopper/inc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Treehopper/)
file(INSTALL ${SOURCE_PATH}/C++/API/Treehopper.Libraries/inc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/Treehopper.Libraries/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/treehopper RENAME copyright)
