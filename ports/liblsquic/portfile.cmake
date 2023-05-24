if(WIN32)
  # The lib uses CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, at least until
  # https://github.com/litespeedtech/lsquic/pull/371 or similar is merged
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO litespeedtech/lsquic
    REF v3.1.1
    SHA512 b4675be355703fea12f4b7d24812b93e739b2dbef04e3d8108b6fbe45dd16c129c9e04e58cdcfdf2a4448ee2edea68565dbd2445a76515bbdc8d9980f4210bee
    HEAD_REF master
    PATCHES 
        disable-asan.patch
        fix-found-boringssl.patch
)

# Submodules
vcpkg_from_github(OUT_SOURCE_PATH LSQPACK_SOURCE_PATH
    REPO litespeedtech/ls-qpack
    REF v2.3.0
    HEAD_REF master
    SHA512 7f5a9dd15bcd32c1bfafbecc5cea4da30f50a852c02d2bd140a2baaafd80ccb822c1701b0d20699af6367e9c712f4fe019741507c44156e9897d25162de0b8b4
)
if(NOT EXISTS "${SOURCE_PATH}/src/ls-hpack/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/liblsquic/ls-qpack")
    file(RENAME "${LSQPACK_SOURCE_PATH}" "${SOURCE_PATH}/src/liblsquic/ls-qpack")
endif()

vcpkg_from_github(OUT_SOURCE_PATH LSHPACK_SOURCE_PATH
    REPO litespeedtech/ls-hpack
    REF v2.3.0
    HEAD_REF master
    SHA512 45866b18042125cbbd008eed2935a938a42e1682030aa52ff4a324ddbad7bf9bd483161352cc8988bae668e132ee8b4b043ddc09d9e0316a66aaefd927ae2d76
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

