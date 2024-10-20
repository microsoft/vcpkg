# Host tool needed by pdal. No bells and whistles.
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF "${VERSION}"
    SHA512 25a5baaafa4949844daa2b423185d19d0a7a6fcd125738212bd62339c824988c6a8d2e3bd68ca1b8aee8facffa2ec0e15c3698c0831573b85c1c7532d8ae5b89
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
