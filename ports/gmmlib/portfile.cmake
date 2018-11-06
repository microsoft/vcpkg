include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF intel-gmmlib-18.3.pre2
    SHA512 9831f6e6f001ba99d5b4860c68697dfc33535a20aa853716534a18b6e4df6c7b95039fff7ffe6f0303cfeb70db4c53ad26a6fa6a8fb6148fa4080e456bff3859
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
