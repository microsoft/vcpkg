include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 4bc3d2017fcf35ee6e69babf9be1e463483cd11c
    SHA512 f17f35ad1692f8dff98d22ed9ec95b0eb3e1e97ff301b87c8c61f137ea0cc21a1e50c65a945e042a0368fd829ac0386f6e21dd0954222eda6cd328c4818d6737
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDISABLE_ARCH_NATIVE=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/xeus/xeus.hpp
        "#ifdef XEUS_STATIC_LIB"
        "#if 1 // #ifdef XEUS_STATIC_LIB"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
