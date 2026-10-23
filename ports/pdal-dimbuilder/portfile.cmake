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
    SHA512 e581f36a1712a6df3e22ed5d40b69d5954e20af52b51a98889a0fbd942d8960a379bec45d9b5524ba29ba48e9722c926eb22b4754545088ada8766e85c106027
    HEAD_REF master
    PATCHES
        namespace-nl.diff
        disable-tests.patch
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
    DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/${VERSION}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
