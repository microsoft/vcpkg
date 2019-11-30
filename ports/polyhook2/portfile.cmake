vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  00709c8621af8a6f9e91200088178e6d9f751097
    SHA512 c6fe9ef9e21de440556cbeb8269e13ef0daafcbc760b04a06e1689d181b6a097c4de9a0f364f7e10f8b0b2f3e419e0ede62aaf4a2a9b16eb2fb57d24eb1b9b5c
    HEAD_REF master
    PATCHES 
        fix-build-error.patch
        fix-build-tests-error.patch
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