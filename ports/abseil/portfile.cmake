if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF "${VERSION}"
    SHA512 f5012885d6b6844a9cf5ed92ad5468b8757db33dfe1364bfb232fff928e06c550c7eb4557f45186a8ac4d18b178df9be267681abab4a6de40823b574afbe9960
    HEAD_REF master
    PATCHES 
        003-force-cxx-17.patch
        004-not-generate-pcfile.patch
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
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DABSL_PROPAGATE_CXX_STD=ON
        ${ABSL_STATIC_RUNTIME_OPTION}
        ${ABSL_MINGW_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME absl CONFIG_PATH lib/cmake/absl)


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
