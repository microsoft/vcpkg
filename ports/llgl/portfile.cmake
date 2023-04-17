
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/LLGL
    REF df46af8974ac6d4f955e76d01b80a8c7e00f1fc8
    SHA512 a6e11573759ced048cc9b9b97dd6abbfb70cbc29770e040b0472d529a1cff14e529b7ed62e647d9b318f6633a41918a29d66762da08e4b093582e1a45284e6d3
    HEAD_REF master
    PATCHES 
        install.patch # See https://github.com/LukasBanana/LLGL/pull/81
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    opengl     LLGL_BUILD_RENDERER_OPENGL
    opengl     LLGL_BUILD_RENDERER_OPENGL_ES3
    direct3d11 LLGL_BUILD_RENDERER_DIRECT3D11 
    direct3d12 LLGL_BUILD_RENDERER_DIRECT3D12
    metal      LLGL_BUILD_RENDERER_METAL
    vulkan     LLGL_BUILD_RENDERER_VULKAN
)

if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_ANDROID)
    set(maybe_unused "LLGL_BUILD_RENDERER_OPENGL")
else()
    set(maybe_unused "LLGL_BUILD_RENDERER_OPENGL_ES3")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LLGL_BUILD_STATIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    MAYBE_UNUSED_VARIABLES ${maybe_unused}
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DLLGL_BUILD_STATIC_LIB=${LLGL_BUILD_STATIC_LIB}    
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LLGL)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
