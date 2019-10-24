vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  00709c8621af8a6f9e91200088178e6d9f751097
    SHA512 c6fe9ef9e21de440556cbeb8269e13ef0daafcbc760b04a06e1689d181b6a097c4de9a0f364f7e10f8b0b2f3e419e0ede62aaf4a2a9b16eb2fb57d24eb1b9b5c
    HEAD_REF master
    PATCHES fix-build-error.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_DLL ON)
    set(BUILD_STATIC OFF)
else()
    set(BUILD_DLL OFF)
    set(BUILD_STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA  
    OPTIONS
      -DFEATURE_INLINENTD=OFF
      -DBUILD_DLL=${BUILD_DLL}
      -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXE OR DEBUG_EXE)
    file(COPY ${EXE} ${DEBUG_EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools )
    file(REMOVE ${EXE} ${DEBUG_EXE})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
    
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)