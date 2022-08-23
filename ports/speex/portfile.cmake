vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/speex
    REF 5dceaaf3e23ee7fd17c80cb5f02a838fd6c18e01 #Speex-1.2.1
    SHA512  d03da906ec26ddcea2e1dc4157ac6dd056e1407381b0f37edd350552a02a7372e9108b4e39ae522f1b165be04b813ee11db0b47d17607e4dad18118b9041636b
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-speex-config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-speex
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/speex/speex.h"
            "extern const SpeexMode"
            "__declspec(dllimport) extern const SpeexMode"
        )
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
