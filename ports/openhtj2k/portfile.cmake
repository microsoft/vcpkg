vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osamu620/OpenHTJ2K
    REF "v${VERSION}"
    SHA512 b9f43dc9a36e24fd26b4e4200557a45905055859418cfd18e8f950c6fb269265397dff4f6518ac7cd415e04f13b094c00165d699c9503cea0d6f119f66d85fdb
    HEAD_REF main
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
    foreach(header IN ITEMS decoder.hpp encoder.hpp openhtj2k_message.hpp)
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
