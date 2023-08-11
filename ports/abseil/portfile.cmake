if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF "${VERSION}"
    SHA512 320295fa687ded05b774741eb4c5285291d44cc14402ec5d997057cb4f53fb3ba54cd162c7a7b1003312b677603a1c25e14bfdbd1fc22ccf4b4443e8a6e3ec02
    HEAD_REF master
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

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB_RECURSE headers "${CURRENT_PACKAGES_DIR}/include/absl/*.h")
    foreach(header IN LISTS ${headers})
        vcpkg_replace_string("${header}"
            "!defined(ABSL_CONSUME_DLL)" "0"
        )
        vcpkg_replace_string("${header}"
            "defined(ABSL_CONSUME_DLL)" "1"
        )
    endforeach()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
