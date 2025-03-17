vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF "${VERSION}"
    SHA512 d6184b87a0fb729397ec2ac2cb8bfd9d10c9d4276e49efa681c66c7c54d1a325305a920332a708e68989cc299d0d1a543a1ceeaf552a9b44ec93084f7bf85ef2
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-msvc-shared.patch
)

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        "-lpthread"
        " "
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        "-lpthread -lm"
        " "
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICORN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
