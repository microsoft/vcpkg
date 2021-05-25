if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} currently doesn't supports UWP.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/LLGL
    REF 8f28437960ed60622e94f4f97b24e842b5a0e9e6
    SHA512 8a6bd4109e977f9def0f04a3d31f7bd4beebbe162c52eaa08a54daf8335871615215ece166e5a9d5b5475b834fd53a26ff9638ff270a2f00c88bab21ed156760
    HEAD_REF master
    PATCHES 
        fix-install-error.patch
        fix-arm64-build-error.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    opengl     LLGL_BUILD_RENDERER_OPENGL
    direct3d11 LLGL_BUILD_RENDERER_DIRECT3D11 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
      file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)