if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/pthreadpool
    REF 560c60d342a76076f0557a3946924c6478470044 #2024-11-04
    SHA512 d23e764e9a02f34210b3b9c5a66dae3b9e8211de6f78ec9b2672c19c48f364f4edb268ab77b1adf2802a3c35c6857deba81e48a658caa1a587fe8f3493a07f59
    PATCHES
        fix-cmakelists.patch
        fix-uwp.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPTHREADPOOL_BUILD_TESTS=OFF
        -DPTHREADPOOL_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
