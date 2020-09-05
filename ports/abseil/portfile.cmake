if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

set(ABSEIL_PATCHES
    fix-uwp-build.patch

    # This patch is an upstream commit, the related PR: https://github.com/abseil/abseil-cpp/pull/637
    fix-MSVCbuildfail.patch

    # Remove this patch in next update, see https://github.com/google/cctz/pull/145
    fix-arm-build.patch

    # This patch is an upstream commit: https://github.com/abseil/abseil-cpp/commit/68494aae959dfbbf781cdf03a988d2f5fc7e4802
    fix-cmake-threads-dependency.patch
)

if("cxx17" IN_LIST FEATURES)
    # in C++17 mode, use std::any, std::optional, std::string_view, std::variant
    # instead of the library replacement types
    list(APPEND ABSEIL_PATCHES fix-use-cxx17-stdlib-types.patch)
else()
    # fore use of library replacement types, otherwise the automatic
    # detection can cause ABI issues depending on which compiler options
    # are enabled for consuming user code
    list(APPEND ABSEIL_PATCHES fix-lnk2019-error.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 06f0e767d13d4d68071c4fc51e25724e0fc8bc74 #commit 2020-03-03
    SHA512 f6e2302676ddae39d84d8ec92dbd13520ae214013b43455f14ced3ae6938b94cedb06cfc40eb1781dac48f02cd35ed80673ed2d871541ef4438c282a9a4133b9
    HEAD_REF master
    PATCHES ${ABSEIL_PATCHES}
)

set(CMAKE_CXX_STANDARD 11)
if("cxx17" IN_LIST FEATURES)
    set(CMAKE_CXX_STANDARD 17)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/absl TARGET_PATH share/absl)

vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/include/absl/copts
                    ${CURRENT_PACKAGES_DIR}/include/absl/strings/testdata
                    ${CURRENT_PACKAGES_DIR}/include/absl/time/internal/cctz/testdata
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/absl/base/config.h
        "#elif defined(ABSL_CONSUME_DLL)" "#elif 1"
    )
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/absl/base/internal/thread_identity.h
        "&& !defined(ABSL_CONSUME_DLL)" "&& 0"
    )
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/absl/container/internal/hashtablez_sampler.h
        "!defined(ABSL_CONSUME_DLL)" "0"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)