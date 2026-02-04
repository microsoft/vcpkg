vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO treehopper-electronics/treehopper-sdk
    REF "${VERSION}"
    SHA512 65b748375b798787c8b59f9657151f340920c939c3f079105b9b78f4e3b775125598106c6dfa4feba111a64d30f007003a70110ac767802a7dd1127a25c9fb14
    HEAD_REF master
    PATCHES
        fix-dependences.patch
        add-cstdint.diff
)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/C++/API/"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DTHREADS_PREFER_PTHREAD_FLAG=ON
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
        THREADS_PREFER_PTHREAD_FLAG
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/C++/API/inc/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/Treehopper/")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
