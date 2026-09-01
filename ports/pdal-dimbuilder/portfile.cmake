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
    SHA512 051e0a8ee2f03ad6eaf55b5843a41626ebc6d2517cf9eeedffda52878fbb9b7d854ea24174e2b3434f69ef41ab244e20e250f6c2c1083325b496489526fb8fea
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
    DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/${VERSION}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
