if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 073cb2e9ec025ae32e2f33f51547083cd8425b0c7297e361b037c71b55a8d2322cd36ac7cabbf8c7a325f80f1cc97947c0aa8aa833dc5fbae5abe28e9c04451a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DARCH=64
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Scripts")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Resource")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/GlobalInfo")

vcpkg_fixup_pkgconfig()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
