vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF 9c4671f2e3a63c0f155d9b2511192d0b5fa7f760 # accessed on 2020-09-14
    SHA512 4c9ed9b675a772f9a6a84692865381130901820cb395b725511e7a9e2cbf4aaa5212a9ef5f87086baf58bb9d729082232b564bd827a205f87b5c1ffc1c53892a
    HEAD_REF master
    PATCHES
        fix-unique_ptr.patch
        fix-unordered_map.patch
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
