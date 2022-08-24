if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF intel-gmmlib-21.3.2
    SHA512 155f7077f3135ff812b9fe759e56fecd595f1c5dde9a377df31a9acedcfeea9d93751badba68077c00929a21cb87e1bd69b8fe3961ac61765fabbc5d6d89e6be
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
