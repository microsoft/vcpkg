# Host tool needed by pdal. No bells and whistles.
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF "${VERSION}"
    #[[
        Attention: pdal must be updated together with pdal-dimbuilder
    #]]
    SHA512 4816c1ef8946937440541b5b8214dd5cbe706ccfbb82e5d67652e983eb6b386a02c1e0ba8ae7e22a0298a65b93953953bc4738d15a33f0f67a39dd6e48dfc076
    HEAD_REF master
    PATCHES
        namespace-nl.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dimbuilder"
    OPTIONS
        "-DNLOHMANN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-DUTFCPP_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/utf8cpp"
)
vcpkg_cmake_build()

vcpkg_copy_tools(TOOL_NAMES dimbuilder
    SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
