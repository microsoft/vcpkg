if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 20230125.3
    SHA512 50509acfc4128fd31435631f71ac8cd0350acd9e290f78502723149016e7f07c9d84182ba99e0938b1873fecda09393d3fd7af8dabfb0d89cdcdd8a69a917e70
    HEAD_REF master
    PATCHES
        fix-dll-support.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cxx17 ABSL_USE_CXX17
)

# With ABSL_PROPAGATE_CXX_STD=ON abseil automatically detect if it is being
# compiled with C++14 or C++17, and modifies the installed `absl/base/options.h`
# header accordingly. This works even if CMAKE_CXX_STANDARD is not set. Abseil
# uses the compiler default behavior to update `absl/base/options.h` as needed.
if (ABSL_USE_CXX17)
    set(ABSL_USE_CXX17_OPTION "-DCMAKE_CXX_STANDARD=17")
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS -DABSL_PROPAGATE_CXX_STD=ON ${ABSL_USE_CXX17_OPTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME absl CONFIG_PATH lib/cmake/absl)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/include/absl/copts"
                    "${CURRENT_PACKAGES_DIR}/include/absl/strings/testdata"
                    "${CURRENT_PACKAGES_DIR}/include/absl/time/internal/cctz/testdata"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/absl/base/config.h"
        "#elif defined(ABSL_CONSUME_DLL)" "#elif 1"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/absl/base/internal/thread_identity.h"
        "&& !defined(ABSL_CONSUME_DLL)" "&& 0"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/absl/container/internal/hashtablez_sampler.h"
        "!defined(ABSL_CONSUME_DLL)" "0"
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
