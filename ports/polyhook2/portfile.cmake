vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  157112f7991768eef51f262486d59c02f18413dc 
    SHA512 3e8919e5a5a66db29848737b2b90bef57e97b55f516b78518abeb004fbdd2c7a3c99c26753024a8f0be5accc830ded8065f473f1d67f7e033ee419626f4212fe
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
