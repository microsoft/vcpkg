vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF "v${VERSION}"
    SHA512 03c8639c07a2c540567ea3fc3429aba2ae52a0ae9687838821995d90d3b1a0e5f33e132b53f1f8a36163fc1a8e68e4beb999d13226ecdc1b5f2e90d75c40bb36
    HEAD_REF master
    PATCHES
        cmake-fix.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        def-callbacks RYML_DEFAULT_CALLBACKS
        dbg           RYML_DBG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRYML_SYSTEM_C4CORE=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/ryml")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ryml)
endif()

# Move headers and natvis to own dir
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/ryml")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml.hpp" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml.hpp")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml_std.hpp" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml_std.hpp")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml.natvis" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml.natvis")

# Fix paths in headers file
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml.hpp" "./c4" "../c4" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml_std.hpp" "./c4" "../c4")

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
