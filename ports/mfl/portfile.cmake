if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

message(WARNING "${PORT} is a C++20 library and requires a corresponding compiler. GCC 10, Clang 10 and MSVC 2019 16.8 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-niel/mfl
    REF v0.0.1
    SHA512 a609b4ff23a01e9f9d9bf60bfa6e0b2346b054cf0c27e74e6da574dcfd2a6ead30dcb8464cf03cae2bb9995f15f01ffda5f862c0ec2744a9ad38b856ff27f073
    HEAD_REF master
    PATCHES
        disable-tests.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mfl)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
