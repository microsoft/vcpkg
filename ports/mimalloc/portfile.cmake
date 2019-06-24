include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF 8a81a6c68adaceeaf3a7735afc6462d3a96d51b4
    SHA512 1f85213e63a9ad7354ed7269ca942d32d7bfe30b499b7a8669ac87772b0bafb06bbcc5780b3f400c4b49e7fbdf83cd86183b2b7686d262560c668e607e0234a5
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(GLOB lib_directories RELATIVE ${CURRENT_PACKAGES_DIR}/lib "${CURRENT_PACKAGES_DIR}/lib/${PORT}-*")
list(GET lib_directories 0 lib_install_dir)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/${lib_install_dir}/cmake)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}/include DESTINATION ${CURRENT_PACKAGES_DIR})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/lib/${lib_install_dir}
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/mimalloc.h
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
