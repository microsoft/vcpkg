# Automatically generated by scripts/boost/generate-ports.ps1

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/cmake
    REF boost-${VERSION}
    SHA512 cd5896f5df84fb0ebae5daa40a0b8dd3ae29ec7c68dc289ac4ef0dc8bc4776d72c82297b2845f5aadd6c6705394ebb62d6bf5df8b4a25622688f6c11d2ae75df
    HEAD_REF master
    PATCHES
        0001-vcpkg-build.patch
        0002-remove-prefix-and-suffix.patch
)

# Beta builds contains a text in the version string
string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" SEMVER_VERSION "${VERSION}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in" "${SOURCE_PATH}/CMakeLists.txt" @ONLY)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost/cmake-build")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_download_distfile(BOOST_LICENSE
    URLS "https://raw.githubusercontent.com/boostorg/boost/refs/tags/boost-${VERSION}/LICENSE_1_0.txt"
    FILENAME "boost-${VERSION}-LICENSE_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
vcpkg_install_copyright(FILE_LIST "${BOOST_LICENSE}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
