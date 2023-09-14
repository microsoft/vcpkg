vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Get rapidyaml src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF "v${VERSION}"
    SHA512 861f1d2c39c5c8d455e8d40e3ecadd828b948c5dea2bcb88ba92686ca77b9a7d69ab2d94407732eab574e4e3c7b319d0f1b31250b18fb513310847192623a2f7
    HEAD_REF master
    PATCHES cmake-fix.patch
)

# Get cmake scripts for rapidyaml
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CMAKE
    REPO biojppm/cmake
    REF 95b2410e31ebf28b56a4fffffef52c7d13d657ad
    SHA512 0aede5089f1db81f976860b20e76f759ddb2c8dceb3b13d3521db65d67b5355083aa370eec245fe7810f3e6702c7ab0e42cae63b0b979c2118c09bf2ae8567ea
    HEAD_REF master
    PATCHES fix_no_find_git.patch

)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext/c4core/cmake")
file(RENAME "${SOURCE_PATH_CMAKE}" "${SOURCE_PATH}/ext/c4core/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        def-callbacks RYML_DEFAULT_CALLBACKS
        dbg           RYML_DBG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
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
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml.hpp" "./c4" "../c4")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml_std.hpp" "./c4" "../c4")

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
