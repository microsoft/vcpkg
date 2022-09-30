vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF v2022.07.12
    SHA512 872fa74520709d6510b798c7adfb7fed34a84b1831e774087515c23a005b0ea76ef7758bb565f0ff9f2153206cf53958621463fba0e055c9d31dc68f687e2b8f
    HEAD_REF master
    PATCHES
        fix-unique_ptr.patch
)

if(VCPKG_HOST_IS_LINUX OR VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_from_git(
        OUT_SOURCE_PATH LSS_SOURCE_PATH
        URL https://chromium.googlesource.com/linux-syscall-support
        REF 7bde79cc274d06451bf65ae82c012a5d3e476b5a
    )
    
    file(RENAME "${LSS_SOURCE_PATH}" "${SOURCE_PATH}/src/third_party/lss")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${CMAKE_CURRENT_LIST_DIR}/check_getcontext.cc" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_HEADERS=ON
)

vcpkg_cmake_install()
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/client/linux/data" "${CURRENT_PACKAGES_DIR}/include/client/linux/sender")

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-breakpad CONFIG_PATH share/unofficial-breakpad)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
