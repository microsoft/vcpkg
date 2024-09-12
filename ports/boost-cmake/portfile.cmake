set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

include("${CMAKE_CURRENT_LIST_DIR}/ref_sha.cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SUPER
    REPO boostorg/boost
    REF ${boost_boost_ref}
    SHA512 ${boost_boost_sha512}
    HEAD_REF master
)

vcpkg_download_distfile(PATCH_MSVC_1940_STILL_VC143
    URLS https://github.com/boostorg/cmake/commit/ae2e6a647187246d6009f80b56ba4c2c8f3a008c.patch?full_index=1
    SHA512 bf36fc86981a2e0ed2a26aa56e88841b7600e39fbf32c76ef9abfc0f19edc67f23518ad84259f62f28d03b10819dd390806bd4866a38cb4a2d9e9eb7dd9f6cb4
    FILENAME boostorg-cmake-boost-1.85.0-0009-msvc-1940-still-vc143.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CMAKE
    REPO boostorg/cmake
    REF ${boost_cmake_ref}
    SHA512 ${boost_cmake_sha512}
    HEAD_REF master
    PATCHES 
      "vcpkg-build.diff"
      "fix-mpi.diff"
      "no-prefix.diff"
      "zstd.diff"
      "add-optional-deps.diff"
      "fix-missing-archs.diff"
      "${PATCH_MSVC_1940_STILL_VC143}"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in" "${SOURCE_PATH_CMAKE}/CMakeLists.txt" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH_CMAKE}")
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH_CMAKE}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost/cmake-build")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH_SUPER}/LICENSE_1_0.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
