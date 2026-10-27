vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osamu620/OpenHTJ2K
    REF "v${VERSION}"
    SHA512 20e69b6b03b5ff4253e8e7bc1fefc165db6c1e0685c6479d76fb9421b7af59e0db0d6cb887aee26f5883c60ffb4a72132a7655186112cb79520e485b32aceb80
    HEAD_REF main
    PATCHES
        fix-sse41-include.patch # https://github.com/osamu620/OpenHTJ2K/pull/474
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools OPENHTJ2K_BUILD_APPS
)

# The SIMD code paths are selected at compile time.  Build x64 for the
# baseline instruction set so the binaries run on any x64 CPU; a triplet can
# override this with -DOPENHTJ2K_TARGET_CPU=x86-64-v3 (AVX2) or x86-64-v4
# (AVX-512) in VCPKG_CMAKE_CONFIGURE_OPTIONS.  ARM64 always uses NEON.
set(target_cpu_options "")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND target_cpu_options -DOPENHTJ2K_TARGET_CPU=generic)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${target_cpu_options}
        -DOPENHTJ2K_BUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_TIFF=ON
    OPTIONS_DEBUG
        -DOPENHTJ2K_BUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/openhtj2k)
vcpkg_fixup_pkgconfig()

# The headers declare the API __declspec(dllimport) on MSVC unless
# OHTJ2K_STATIC is defined; the CMake target and the .pc file define it for
# the static library, but code that only includes the headers does not.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(header IN ITEMS decoder.hpp encoder.hpp)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/open_htj2k/interface/${header}"
            "#if defined(_MSC_VER) && !defined(OHTJ2K_STATIC)"
            "#if 0 // static library"
        )
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES open_htj2k_dec open_htj2k_enc AUTO_CLEAN)
endif()

# ThreadPool.hpp, compiled into the library, carries a second copyright
# holder that LICENSE does not name in this release (added upstream by
# https://github.com/osamu620/OpenHTJ2K/pull/474): install its notice too.
file(READ "${SOURCE_PATH}/source/core/common/ThreadPool.hpp" threadpool_source)
string(FIND "${threadpool_source}" "\n\n" threadpool_notice_end)
string(SUBSTRING "${threadpool_source}" 0 ${threadpool_notice_end} threadpool_notice)
string(REGEX REPLACE "(^|\n)// ?" "\\1" threadpool_notice "${threadpool_notice}")
file(WRITE "${CURRENT_BUILDTREES_DIR}/ThreadPool-notice.txt"
    "source/core/common/ThreadPool.hpp:\n\n${threadpool_notice}\n")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${CURRENT_BUILDTREES_DIR}/ThreadPool-notice.txt"
)
