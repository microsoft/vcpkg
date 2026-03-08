if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 c54581e4927bfedd7cb4084111cce69c9ee14f0047f6d16d26358e9d41feb8d28d5158f7fbdfbe4980dae904e7c2065deed19fd2f91e32b49fd7b984d47c0f44
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Scripts")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Resource")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/GlobalInfo")

vcpkg_fixup_pkgconfig()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
