if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 63e676291f137880e2b4bd2091c3055a6ec2b0bb62ebd47a96c0a462e8434d1321563c4e2f0d2e40d79383a23ef0bb8ceb0f0f89a8ae94feb409440e43149e6e
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
