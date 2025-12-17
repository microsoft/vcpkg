if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF "${VERSION}"
    SHA512 7083b73c3cf763f6f7a7edb70a5171f44d27045a0f5e52ca043e0a86379af2c50cf85dbfea30ebaa22a7bb2929452581d26b1ba18945023b057267d4c3bad2f7
    HEAD_REF master
    PATCHES 
        001-mingw-dll.patch # Upstreamed (not yet in a release): https://github.com/abseil/abseil-cpp/commit/f2dee57baf19ceeb6d12cf9af7cbb3c049396ba5
        002-string-view.patch
        003-force-cxx-17.patch
)

set(ABSL_TEST_HELPERS_OPTIONS "")
if("test-helpers" IN_LIST FEATURES)
    set(ABSL_TEST_HELPERS_OPTIONS "-DABSL_BUILD_TEST_HELPERS=ON" "-DABSL_USE_EXTERNAL_GOOGLETEST=ON" "-DABSL_FIND_GOOGLETEST=ON")
endif()

set(ABSL_STATIC_RUNTIME_OPTION "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set(ABSL_STATIC_RUNTIME_OPTION "-DABSL_MSVC_STATIC_RUNTIME=ON")
endif()

set(ABSL_MINGW_OPTIONS "")
if(VCPKG_TARGET_IS_MINGW)
    # LIBRT-NOTFOUND is needed since the system librt may be found by cmake in
    # a cross-compile setup.
    # See https://github.com/pywinrt/pywinrt/pull/83 for the FIReference
    # definition issue.
    set(ABSL_MINGW_OPTIONS "-DLIBRT=LIBRT-NOTFOUND"
        "-DCMAKE_CXX_FLAGS=-D____FIReference_1_boolean_INTERFACE_DEFINED__")
    # Specify ABSL_BUILD_MONOLITHIC_SHARED_LIBS=ON when VCPKG_LIBRARY_LINKAGE is dynamic to match Abseil's Windows (MSVC) defaults
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        vcpkg_list(APPEND ABSL_MINGW_OPTIONS "-DABSL_BUILD_MONOLITHIC_SHARED_LIBS=ON")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DABSL_PROPAGATE_CXX_STD=ON
        ${ABSL_TEST_HELPERS_OPTIONS}
        ${ABSL_STATIC_RUNTIME_OPTION}
        ${ABSL_MINGW_OPTIONS}
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
