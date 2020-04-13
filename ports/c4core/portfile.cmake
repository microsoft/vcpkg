vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_fail_port_install(ON_ARCH "arm" "arm64")

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF bc4de0291bb96ae509ee99a54f139563cf14638e
    SHA512 2c0c4511cb43f34492b6d0d8dfef90623dfacb6ae43f6a6173fbf9efa63f7a018235ec9dcd9a211a3cd393c2114adb39a4276df94e2d23f9c354d644a36e51a0
    HEAD_REF master
)

set(COMMIT_HASH a0f0c17bfc9a9a91cc72891539b513c129c6d122)

# Get cmake scripts for c4core & rapidyaml
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${COMMIT_HASH}.zip"
    FILENAME "cmake-${COMMIT_HASH}.zip"
    SHA512 4fbc711f3120501fa40733c3b66e34cd6a7e1b598b1378fbb59d1a87c88290a03d021f5176634089da41682fd918d7e27c6c146052dec54d7e956be15f12744f
)

vcpkg_extract_source_archive(
    ${CMAKE_ARCHIVE}
    "${CURRENT_BUILDTREES_DIR}/src/deps" 	
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(COPY "${CURRENT_BUILDTREES_DIR}/src/deps/cmake-${COMMIT_HASH}" DESTINATION ${SOURCE_PATH})
file(RENAME "${SOURCE_PATH}/cmake-${COMMIT_HASH}" "${SOURCE_PATH}/cmake")

set(COMMIT_HASH 78e525c6e74df6d62d782864a52c0d279dcee24f)

vcpkg_download_distfile(DEBUGBREAK_ARCHIVE
    URLS "https://github.com/biojppm/debugbreak/archive/${COMMIT_HASH}.zip"
    FILENAME "debugbreak-${COMMIT_HASH}.zip"
    SHA512 25f3d45b09ce362f736fac0f6d6a6c7f2053fec4975b32b0565288893e4658fd0648a7988c3a5fe0e373e92705d7a3970eaa7cfc053f375ffb75e80772d0df64
)

vcpkg_extract_source_archive(
    ${DEBUGBREAK_ARCHIVE}
    "${CURRENT_BUILDTREES_DIR}/src/deps" 	
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ext/debugbreak")
file(COPY "${CURRENT_BUILDTREES_DIR}/src/deps/debugbreak-${COMMIT_HASH}" DESTINATION "${SOURCE_PATH}/ext")
file(RENAME "${SOURCE_PATH}/ext/debugbreak-${COMMIT_HASH}" "${SOURCE_PATH}/ext/debugbreak")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/c4core)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/c4core)
endif()

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" "${_contents}")

# Fix missing header (see c4/error.hpp)
file(RENAME "${CURRENT_PACKAGES_DIR}/include/c4/extern/debugbreak" "${CURRENT_PACKAGES_DIR}/include/debugbreak")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/c4core" RENAME copyright)
