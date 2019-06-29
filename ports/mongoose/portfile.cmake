include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cesanta/mongoose
    REF 6.15
    SHA512 d736aeb9ccb7a67fb8180ed324d3fa26e005bfc2ede1db00d73349976bfcfb45489ce3efb178817937fae3cd9f6a6e9c4b620af8517e3ace9c53b9541539bdde
    HEAD_REF master
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DMONGOOSE_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DMONGOOSE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME unofficial-${PORT})
