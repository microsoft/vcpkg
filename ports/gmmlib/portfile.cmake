if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 d5a6da43f4bdcb2a138c249e197b2e441d0999e89867aa66dfa68cbfc6982e631a7df29fd213a72a57b31cb29366f654343cb6b77a46f22e54bfa5432310e053
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
