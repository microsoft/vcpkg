vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ultravideo/uvg266 
    REF v${VERSION}
    SHA512 892b0732516fe2639f93b250bbed342da8134deeaa6f0ccb429ff8451df727f971c7ee284fef93eaa431c5c54a8b8789ffc853d8b45ae93433ba17007989bbae
    HEAD_REF master
    PATCHES
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    SET(BUILD_SHARED_LIBS OFF)
else()
    SET(BUILD_SHARED_LIBS ON)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    SET(UVG266_CMAKE_BUILD_TYPE "Debug")
else()
    SET(UVG266_CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTS=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DGIT_SUBMODULE=OFF
        -DCMAKE_BUILD_TYPE=${UVG266_CMAKE_BUILD_TYPE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES uvg266 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
