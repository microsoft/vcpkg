vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Reflect
    REF d920b79
    SHA512 3e94adb9ec80f356bd51665f10e3e1d8e6236632d259a22fab97a156c6cf6fcbd1afc102ac4578fa3f3725b6cc0cbdf530c85fa133154d6c4e313324c1d6bbf4
    HEAD_REF master
    PATCHES
        cmake-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

if(DEFINED ENV{VULKAN_SDK})
    message(STATUS "VULKAN_SDK env var found: $ENV{VULKAN_SDK}")
else()
    message(FATAL_ERROR "VULKAN_SDK env var not found!")
endif()

message(STATUS "INSTAL INCLUDE DIR: ${CMAKE_INSTALL_INCLUDEDIR}")


vcpkg_install_cmake()
# vcpkg_fixup_cmake_targets()

# file(COPY "${SOURCE_PATH}/spirv_reflect.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv-reflect/")
# file(COPY "${SOURCE_PATH}/include/spirv/unified1/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv-reflect/include/spirv/unified1/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/spirv-reflect" RENAME copyright)