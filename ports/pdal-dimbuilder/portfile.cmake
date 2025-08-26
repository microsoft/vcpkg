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
    SHA512 4a7f4356530a3d2c1ecde8c3aa7cfee052eb7d57a33e5e8bf7699e05bf0994bfc5552562b22af744879866336deea228cee75b543b89399fbeb952c400c33ea2
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
