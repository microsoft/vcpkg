if(VCPKG_TARGET_IS_WINDOWS)
  # The lib uses CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, at least until
  # https://github.com/litespeedtech/lsquic/pull/371 or similar is merged
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/lsquic
    REF v${VERSION}
    SHA512 2f1f01761499f834d5ef43a80e2f9eb94f008c17bc1417eef6cde42d33de485627a9b921fc4ebb288b87cb2c9478fb7149d426a60a0e9abbf5067b9edfb97cde
    HEAD_REF master
    PATCHES
        disable-asan.patch
        fix-found-boringssl.patch
)

# Submodules
vcpkg_from_github(OUT_SOURCE_PATH LSQPACK_SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF v2.6.2
    HEAD_REF master
    SHA512 9b38ba1b4b12d921385a285e8c833a0ae9cdcc153cff4f1857f88ceb82174304decb5fccbdf9267d08a21c5a26c71fdd884dcacd12afd19256a347a8306b9b90
)
if(NOT EXISTS "${SOURCE_PATH}/src/ls-hpack/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/liblsquic/ls-qpack")
    file(RENAME "${LSQPACK_SOURCE_PATH}" "${SOURCE_PATH}/src/liblsquic/ls-qpack")
endif()

vcpkg_from_github(OUT_SOURCE_PATH LSHPACK_SOURCE_PATH
    REPO litespeedtech/ls-hpack
    REF v2.3.4
    HEAD_REF master
    SHA512 86a3c869597f4f181e3ecc9648a7ce73139c8e201547072203ad60802a1df37885389c332231efb0521b1bf2357cdb9d866ade48f59af1cbb6c5cbba8148a0ff
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

