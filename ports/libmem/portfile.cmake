vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF 5.0.2
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
    PATCHES
        fix_DLL.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION "${SOURCE_PATH}"
)

# Define the LM_EXPORT macro for static builds on Windows OS
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE EQUAL "static") 
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DLM_EXPORT")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        GENERATOR "NMake Makefiles"
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        DISABLE_PARALLEL_CONFIGURE
    )
endif()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Uncomment if needed for CMake target fixup
vcpkg_fixup_cmake_targets(CONFIG_PATH lib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
