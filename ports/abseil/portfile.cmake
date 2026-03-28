if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF "${VERSION}"
    SHA512 daeed3943d9fc2ecdb090f77f634f2b14ccffa4dcc9c2588489f4c3a52bca7da33def1b157a4e31cf732a8b52b4f83ecbf4de6cf3ec17c317ec9be1a1112bc63
    HEAD_REF master
    PATCHES 
        003-force-cxx-17.patch
        fix-heterogeneous_lookup_testing-target.patch
)


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
    OPTIONS
        -DABSL_PROPAGATE_CXX_STD=ON
        -DABSL_BUILD_TESTING=OFF 
        -DABSL_BUILD_TEST_HELPERS=OFF
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
