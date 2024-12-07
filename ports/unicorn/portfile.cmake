vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF "${VERSION}"
    SHA512 d6184b87a0fb729397ec2ac2cb8bfd9d10c9d4276e49efa681c66c7c54d1a325305a920332a708e68989cc299d0d1a543a1ceeaf552a9b44ec93084f7bf85ef2
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICORN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB del_files "${CURRENT_PACKAGES_DIR}/lib/*.a" "${CURRENT_PACKAGES_DIR}/debug/lib/*.a")
    if(del_files)
        file(REMOVE ${del_files})
    endif()

    file(GLOB_RECURSE LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*.lib")
    file(GLOB_RECURSE DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")

    foreach(file ${LIB_FILES} ${DEBUG_LIB_FILES})
        if(file MATCHES "unicorn.lib")
            file(REMOVE ${file})
        endif()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
