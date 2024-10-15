vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF 5.0.2
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
)
#    PATCHES
#        fix_DLL.patch

# Define the LM_EXPORT macro for Windows OS or shared builds
if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_LIBRARY_LINKAGE EQUAL "shared") 
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DLM_EXPORT")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKEYSTONE_BUILD_STATIC=${KEYSTONE_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${KEYSTONE_BUILD_SHARED}
        -DITK_MSVC_STATIC_RUNTIME_LIBRARY=OFF
        -DITK_MSVC_STATIC_CRT=OFF
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CAPSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CAPSTONE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKEYSTONE_BUILD_STATIC=${ZSTD_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${ZSTD_BUILD_SHARED}
        -DITK_MSVC_STATIC_RUNTIME_LIBRARY=OFF
        -DITK_MSVC_STATIC_CRT=OFF
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LLVM_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LLVM_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKEYSTONE_BUILD_STATIC=${LLVM_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${LLVM_BUILD_SHARED}
        -DITK_MSVC_STATIC_RUNTIME_LIBRARY=OFF
        -DITK_MSVC_STATIC_CRT=OFF
)

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND ADDITIONAL_OPTIONS
    -DITK_MSVC_STATIC_RUNTIME_LIBRARY=OFF
    -DITK_MSVC_STATIC_CRT=OFF
    )
endif()


file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION "${SOURCE_PATH}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        GENERATOR "NMake Makefiles"
    )
else()
    vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        DISABLE_PARALLEL_CONFIGURE
    )
endif()
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Uncomment if needed for CMake target fixup
vcpkg_cmake_config_fixup(CONFIG_PATH lib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
