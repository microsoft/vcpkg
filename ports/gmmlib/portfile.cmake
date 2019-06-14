include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF intel-gmmlib-19.1.2
    SHA512 fcc0beedfc3716b6204627f7daa5e0a5aec720b2a29ab2f8262b613a11d31bfe14dc8476513515d8470cf7d66f58d109ed4d5cf203e041228f53a64cb4a6c243
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
