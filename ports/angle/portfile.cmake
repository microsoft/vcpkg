include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(WARNING "Building with a gcc version less than 6.1 is not supported.")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ANGLE_CPU_BITNESS ANGLE_IS_64_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF 6a02f06dfd4ec5e0f9efb553059ce65535f4b312
    SHA512 6e71bd916781751e1f2f1850007d312ed917b11eda2fef6767bc4e61d1740825e2cf4ee4ac2477c93f7df4bd13b32dbfe7014d11a474333d20f0e1a2a99f80c6
    PATCHES 
        001-fix-uwp.patch
        002-fix-linux.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/commit.h DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
    OPTIONS
        -D${ANGLE_CPU_BITNESS}=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-angle TARGET_PATH share/unofficial-angle)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angle RENAME copyright)
