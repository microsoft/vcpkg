vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(
    ON_ARCH "arm" "arm64"
    ON_TARGET "OSX"
)

# Get rapidyaml src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF db387345abf9cd6710e0c4a487a476bfd176fea3
    SHA512 4dda145b561e3b8420f89ad01e42eb5056b51a8a28a47f3b8c91bb0a2a6420d1842016a23cbb17d9f119ebce0e2e404b4f4fb67d71bf0d3c87aa81f346c6cfe2
    HEAD_REF master
    PATCHES cmake-fix.patch
)

set(COMMIT_HASH 71c211187b8c52a13d5c59a7979f2ccf8429e350)

# Get cmake scripts for rapidyaml
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${COMMIT_HASH}.zip"
    FILENAME "cmake-${COMMIT_HASH}.zip"
    SHA512 d15884d985a477df47ead9c5c486cfdeb1df8b6de4f308c36bd7a8c0e901fb876980a2a4f239abd8ecb1fb0baf75ad559ca0780b50c84070762f8cbfe55cb9d2
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
