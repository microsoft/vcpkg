include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF f6c91364b0911a7513e9543fd874360ec8901742 # intel-gmmlib-20.3.1
    SHA512 c46d5cba30db1d06134d2606ad9806a84b0e1248313a61c5d073fc5fe7570b864a4d5e9cf73dc6832102ace476839dbff1e3782f08a4cdcb62c04c40708a5710
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DARCH=64
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/gmmlib/copyright COPYONLY)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Scripts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Resource)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/GlobalInfo)
