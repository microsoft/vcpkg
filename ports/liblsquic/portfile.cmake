if(VCPKG_TARGET_IS_WINDOWS)
  # The lib uses CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, at least until
  # https://github.com/litespeedtech/lsquic/pull/371 or similar is merged
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/lsquic
    REF v${VERSION}
    SHA512 40d742779bfa2dc6fdaf0ee8e9349498d373dcffcc6dd27867c18d87309a288ea6811d693043b5d98364d816b818b49445214497475844201241193c0f37b349
    HEAD_REF master
    PATCHES 
        disable-asan.patch
        fix-found-boringssl.patch
)

# Submodules
vcpkg_from_github(OUT_SOURCE_PATH LSQPACK_SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF v2.5.3
    HEAD_REF master
    SHA512 f90502c763abc84532f33d1b8f952aea7869e4e0c5f6bd344532ddd51c4a180958de4086d88b9ec96673a059c806eec9e70007651d4d4e1a73395919dee47ce0
)
if(NOT EXISTS "${SOURCE_PATH}/src/ls-hpack/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/liblsquic/ls-qpack")
    file(RENAME "${LSQPACK_SOURCE_PATH}" "${SOURCE_PATH}/src/liblsquic/ls-qpack")
endif()

vcpkg_from_github(OUT_SOURCE_PATH LSHPACK_SOURCE_PATH
    REPO litespeedtech/ls-hpack
    REF v2.3.2
    HEAD_REF master
    SHA512 45d6c8296e8eee511e6a083f89460d5333fc9a49bc078dac55fdec6c46db199de9f150379f02e054571f954a5e3c79af3864dbc53dc57d10a8d2ed26a92d4278
)
if(NOT EXISTS "${SOURCE_PATH}/src/lshpack/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/lshpack")
    file(RENAME "${LSHPACK_SOURCE_PATH}" "${SOURCE_PATH}/src/lshpack")
endif()

# Configuration
vcpkg_find_acquire_program(PERL)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LSQUIC_SHARED_LIB)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    "-DPERL=${PERL}"
    "-DPERL_EXECUTABLE=${PERL}"
    "-DLSQUIC_SHARED_LIB=${LSQUIC_SHARED_LIB}"
    "-DBORINGSSL_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
    -DLSQUIC_BIN=OFF
    -DLSQUIC_TESTS=OFF
  OPTIONS_RELEASE
    "-DBORINGSSL_LIB=${CURRENT_INSTALLED_DIR}/lib"
  OPTIONS_DEBUG
    "-DBORINGSSL_LIB=${CURRENT_INSTALLED_DIR}/debug/lib"
    -DLSQUIC_DEVEL=ON
)

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS)
  # Upstream removed installation of this header after merging changes
  file(INSTALL "${SOURCE_PATH}/wincompat/vc_compat.h" DESTINATION "${CURRENT_INSTALLED_DIR}/include/lsquic")
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME lsquic)

# Concatenate license files and install
vcpkg_install_copyright(FILE_LIST 
  "${SOURCE_PATH}/LICENSE" 
  "${SOURCE_PATH}/LICENSE.chrome"
)

# Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

