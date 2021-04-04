if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 997aaf3a28308eba1b9156aa35ab7bca9688e9f6 #LTS 20210324
    SHA512 bdd80a2278eef121e8837791fdebca06e87bfff4adc438c123e0ce11efc42a8bd461edcbbe18c0eee05be2cd6100f9acf8eab3db58ac73322b5852e6ffe7c85b
    HEAD_REF master
    PATCHES
        # in C++17 mode, use std::any, std::optional, std::string_view, std::variant
        # instead of the library replacement types
        # in C++11 mode, force use of library replacement types, otherwise the automatic
        # detection can cause ABI issues depending on which compiler options
        # are enabled for consuming user code
        fix-cxx-standard.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cxx17 ABSL_USE_CXX17
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
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
