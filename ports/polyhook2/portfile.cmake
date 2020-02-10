vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  f5051a47888cc0960e6592f0c65dec2b214f9139 
    SHA512 a08f2433bfa26282458bb8327bb5fc366ac3f80eda4b40324d197ea58e11cc05d877b3ff2ea9fc13a269b1f9a051437dff5baec93be09d8df5f69a8e7f454d83
    HEAD_REF master
    PATCHES 
        fix-build-error.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool BUILD_TOOLS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC ON)
else()
    set(BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA  
    OPTIONS ${FEATURE_OPTIONS}
      -DFEATURE_INLINENTD=OFF
      -DBUILD_DLL=ON
      -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)    
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)