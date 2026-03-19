vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDGpu
    REF v${VERSION}
    SHA512 ff8c0caa83b68a6507f30935d0d7cb5c64b0ba882e93e85c868d4f44415b1545d562c529656b7bc86b4ed5a1e4635d5b70c11855d347a85220f67cfae9e750cf
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
	kdgpuutils   KDGPU_BUILD_KDGPUUTILS
	kdgpukdgui   KDGPU_BUILD_KDGPUKDGUI
	kdgpuexample KDGPU_BUILD_KDGPUEXAMPLE
	openxr	     KDGPU_BUILD_KDXR
	hlsl	     KDGPU_HLSL_SUPPORT
	slang	     KDGPU_SLANG_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KDGPU_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DKDGPU_BUILD_SHARED_LIBS=${KDGPU_BUILD_SHARED_LIBS}
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
        -DKDGPU_BUILD_EXAMPLES=OFF
        -DKDGPU_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Fix up optional components only if they exist
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/KDGpuUtils")
    vcpkg_cmake_config_fixup(PACKAGE_NAME kdgputuils CONFIG_PATH lib/cmake/KDGpuUtils DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/KDGpuKDGui")
    vcpkg_cmake_config_fixup(PACKAGE_NAME kdgpukdgui CONFIG_PATH lib/cmake/KDGpuKDGui DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/KDXr")
    vcpkg_cmake_config_fixup(PACKAGE_NAME kdxr CONFIG_PATH lib/cmake/KDXr DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/KDGpuExample")
    vcpkg_cmake_config_fixup(PACKAGE_NAME kdgpuexample CONFIG_PATH lib/cmake/KDGpuExample DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME kdgpu CONFIG_PATH lib/cmake/KDGpu)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*.txt")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
