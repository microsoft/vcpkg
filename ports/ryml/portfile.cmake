vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(
    ON_ARCH "arm" "arm64"
    ON_TARGET "OSX"
)

# Get rapidyaml src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF ec23e87007ccc39c6132345c154b267de9381706
    SHA512 7d349c0dd58da814dad02de88a5c54394ef8d77e7db3014fb5fb684d519e35604d45f5d16db5ed6ed8ccb52b1ed4a4dbc91e717a091b54b04dc18901800e12c1
    HEAD_REF master
    PATCHES cmake-fix.patch
)

set(COMMIT_HASH a0f0c17bfc9a9a91cc72891539b513c129c6d122)

# Get cmake scripts for rapidyaml
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${COMMIT_HASH}.zip"
    FILENAME "cmake-${COMMIT_HASH}.zip"
    SHA512 4fbc711f3120501fa40733c3b66e34cd6a7e1b598b1378fbb59d1a87c88290a03d021f5176634089da41682fd918d7e27c6c146052dec54d7e956be15f12744f
)

vcpkg_extract_source_archive(
    ${CMAKE_ARCHIVE}
    "${CURRENT_BUILDTREES_DIR}/src/deps" 	
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext/c4core/cmake")
file(COPY "${CURRENT_BUILDTREES_DIR}/src/deps/cmake-${COMMIT_HASH}" DESTINATION "${SOURCE_PATH}/ext/c4core")
file(RENAME "${SOURCE_PATH}/ext/c4core/cmake-${COMMIT_HASH}" "${SOURCE_PATH}/ext/c4core/cmake")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/ryml" RENAME copyright)
