include(vcpkg_common_functions)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ANGLE_CPU_BITNESS ANGLE_IS_64_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "ANGLE currently only supports being built as a dynamic library")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF chromium/3672
    SHA512 dd6a05f0f1f4544b8646c41ffcb4d5e3b41f5261771ada47889345a24d4e55e6370df55a26c354a7073efcde307644cec6c6064ea6fe498ed6b52c3017249f81
)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-fix-uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/commit.h DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}    
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
    OPTIONS
        -D${ANGLE_CPU_BITNESS}=1
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-angle)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/angle ${CURRENT_PACKAGES_DIR}/share/unofficial-angle)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angle RENAME copyright)
