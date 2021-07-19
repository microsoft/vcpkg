vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(
    ON_TARGET "OSX"
)

# Get rapidyaml src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF a1d5ed7c8ace0ab14340ba19dfed60f280eddac0
    SHA512 27a7b7a3ee2f6bb63600907fbc2307b7da13a13b88605c0e7b628fe26878b120d0df9bc221d7d495c5212543db00f0b570f351e7e3e3bebb0c785a676a4d2469
    HEAD_REF master
    PATCHES cmake-fix.patch
)

set(CM_COMMIT_HASH c6de791cd37ea3dc6bcb967819cb74b4f054a8f2)

# Get cmake scripts for rapidyaml
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${CM_COMMIT_HASH}.zip"
    FILENAME "cmake-${CM_COMMIT_HASH}.zip"
    SHA512 2d3f2d8d207f7d9c583b1f0bb35a1f4e0ed571ecdf7d5e745467f4f39cd82b860fc84d220c48a2d01e0ab805ce750133b73006b2f19920c95b1f85c7431459e3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH_CMAKE
    ARCHIVE ${CMAKE_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext/c4core/cmake")
file(RENAME ${SOURCE_PATH_CMAKE} "${SOURCE_PATH}/ext/c4core/cmake")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/ryml)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ryml)
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

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
