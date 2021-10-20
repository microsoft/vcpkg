vcpkg_download_distfile(ARCHIVE
    URLS "http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.0.0.tar.gz"
    FILENAME "cfitsio-4.0.0.tar.gz"
    SHA512 a5b20bd6ad648450e99167f63813cc7523347aadfc9f85d2c0ed3ba7e4516b3bb6bc0851f209268f2cb045cdacc43a3da9e4506af4581f806ab9f4de248065fa
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-fix-dependencies-and-export-cmake-targets.patch
        0002-add-Wno-error-implicit-funciton-declaration-to-cmake.patch
        0003-fix-LNK2019-of-strtok_r-in-pthreads-feature.patch
        0004-pkg-config.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl        USE_CURL
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_PTHREADS=${WITH_PTHREADS}
        "-DPKG_CONFIG_REQUIRES_PRIVATE=${PKG_CONFIG_REQUIRES_PRIVATE}"
        -DPKG_CONFIG_LIBS=-lcfitsio
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-cfitsio)

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake" ASSIMP_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake" "
include(CMakeFindDependencyMacro)
${FIND_CURL_DEPENDENCY}
${FIND_PTHREADS_DEPENDENCY}
find_dependency(ZLIB)
${ASSIMP_CONFIG}
")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake"
    "cmake_policy(VERSION 2.6)"
    "cmake_policy(VERSION 2.6)\r\n\
# Required for the evaluation of \"if(@BUILD_SHARED_LIBS@)\" below to function\r\n\
cmake_policy(SET CMP0012 NEW)\r\n"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/unistd.h" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)