vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/tvm-ffi
    REF "v${VERSION}"
    SHA512 6eb8f4299f643ef5b29281505bd991a9f71a4cab25809cf1cc510c34c7c4cf924a16ab2b65bc5eb76002bde5d6624e4e199eac687e3c894c0558736547a55af7
    HEAD_REF main
    PATCHES
        cmake-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTVM_FFI_USE_LIBBACKTRACE=OFF
        -DTVM_FFI_BUILD_TESTS=OFF
        -DTVM_FFI_BUILD_PYTHON_MODULE=OFF
)

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(config IN ITEMS "" "/debug")
        if(EXISTS "${CURRENT_PACKAGES_DIR}${config}/lib/tvm_ffi.dll")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${config}/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}${config}/lib/tvm_ffi.dll"
                        "${CURRENT_PACKAGES_DIR}${config}/bin/tvm_ffi.dll")
        endif()
    endforeach()
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
