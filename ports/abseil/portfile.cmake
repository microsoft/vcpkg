if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF "${VERSION}"
    SHA512 8312acf0ed74fa28c6397f3e41ada656dbd5ca2bf8db484319d74b144ad19c0ebdc77f7f03436be6c6ca1cde706b9055079233cf0d6b5ada4ca48406f8a55dd8
    HEAD_REF master
)

# With ABSL_PROPAGATE_CXX_STD=ON abseil automatically detect if it is being
# compiled with C++14 or C++17, and modifies the installed `absl/base/options.h`
# header accordingly. This works even if CMAKE_CXX_STANDARD is not set. Abseil
# uses the compiler default behavior to update `absl/base/options.h` as needed.
set(ABSL_USE_CXX17_OPTION "")
if("cxx17" IN_LIST FEATURES)
    set(ABSL_USE_CXX17_OPTION "-DCMAKE_CXX_STANDARD=17")
endif()

set(ABSL_TEST_HELPERS_OPTIONS "")
if("test-helpers" IN_LIST FEATURES)
    set(ABSL_TEST_HELPERS_OPTIONS "-DABSL_BUILD_TEST_HELPERS=ON" "-DABSL_USE_EXTERNAL_GOOGLETEST=ON" "-DABSL_FIND_GOOGLETEST=ON")
endif()

set(ABSL_STATIC_RUNTIME_OPTION "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set(ABSL_STATIC_RUNTIME_OPTION "-DABSL_MSVC_STATIC_RUNTIME=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DABSL_PROPAGATE_CXX_STD=ON
        ${ABSL_USE_CXX17_OPTION}
        ${ABSL_TEST_HELPERS_OPTIONS}
        ${ABSL_STATIC_RUNTIME_OPTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME absl CONFIG_PATH lib/cmake/absl)

if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX)
    file(APPEND "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/absl_time.pc" "Libs.private: -framework CoreFoundation\n")
    if(NOT VCPKG_BUILD_TYPE)
        file(APPEND "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/absl_time.pc" "Libs.private: -framework CoreFoundation\n")
    endif()
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/include/absl/copts"
                    "${CURRENT_PACKAGES_DIR}/include/absl/strings/testdata"
                    "${CURRENT_PACKAGES_DIR}/include/absl/time/internal/cctz/testdata"
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/absl/base/config.h" "defined(ABSL_CONSUME_DLL)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/absl/base/internal/thread_identity.h" "defined(ABSL_CONSUME_DLL)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
