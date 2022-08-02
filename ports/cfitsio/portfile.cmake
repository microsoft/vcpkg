vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-3.49.tar.gz"
    FILENAME "cfitsio-3.49.tar.gz"
    SHA512 9836a4af3bbbfed1ea1b4c70b9d500ac485d7c3d8131eb8a25ee6ef6662f46ba52b5161c45c709ed9a601ff0e9ec36daa5650eaaf4f2cc7d6f4bb5640f10da15
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-fix-dependencies.patch
        0002-export-cmake-targets.patch
        0003-add-Wno-error-implicit-funciton-declaration-to-cmake.patch
        0004-pkg-config.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl        UseCurl
)

set(PKG_CONFIG_REQUIRES_PRIVATE zlib)
if ("curl" IN_LIST FEATURES)
    set(FIND_CURL_DEPENDENCY "find_dependency(CURL CONFIG)")
    string(APPEND PKG_CONFIG_REQUIRES_PRIVATE " libcurl")
endif()

if ("pthreads" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(WITH_PTHREADS ON)
        set(FIND_PTHREADS_DEPENDENCY "find_dependency(pthreads)")
    else()
        message(WARNING "Feature pthreads only support Windows, disable it now.")
        set(WITH_PTHREADS OFF)
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_PTHREADS=${WITH_PTHREADS}
        "-DPKG_CONFIG_REQUIRES_PRIVATE=${PKG_CONFIG_REQUIRES_PRIVATE}"
        -DPKG_CONFIG_LIBS=-lcfitsio
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-cfitsio TARGET_PATH share/unofficial-cfitsio)

file(READ ${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake ASSIMP_CONFIG)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake "
include(CMakeFindDependencyMacro)
${FIND_CURL_DEPENDENCY}
${FIND_PTHREADS_DEPENDENCY}
find_dependency(ZLIB)
${ASSIMP_CONFIG}
")

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake
    "cmake_policy(VERSION 2.6)"
    "cmake_policy(VERSION 2.6)\r\n\
# Required for the evaluation of \"if(@BUILD_SHARED_LIBS@)\" below to function\r\n\
cmake_policy(SET CMP0012 NEW)\r\n"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/unistd.h ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/FindPthreads.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
