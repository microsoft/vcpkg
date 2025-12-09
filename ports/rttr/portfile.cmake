vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rttrorg/rttr
    REF 7edbd580cfad509a3253c733e70144e36f02ecd4 
    SHA512 17432728037bc0f8e346c6bd01298c6ee3a4714c83505b2cf1bc23305acea5cc55925e7fc28a8cf182b6ba26abdc9d40ea2f5b168615c030d5ebeec9a8961636
    HEAD_REF master
    PATCHES
        fix-directory-output.patch
        Fix-depends.patch
        remove-owner-read-perms.patch
        disable-unsupport-header.patch
        disable-werrorr.patch
)

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static" AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
    set(BUILD_STATIC ON)
    set(BUILD_RTTR_DYNAMIC OFF)
    set(BUILD_WITH_STATIC_RUNTIME_LIBS OFF)
elseif("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic" AND "${VCPKG_CRT_LINKAGE}" STREQUAL "static")
    set(BUILD_STATIC OFF)
    set(BUILD_RTTR_DYNAMIC OFF)
    set(BUILD_WITH_STATIC_RUNTIME_LIBS ON)
elseif("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic" AND "${VCPKG_CRT_LINKAGE}" STREQUAL "dynamic")
    set(BUILD_STATIC OFF)
    set(BUILD_RTTR_DYNAMIC ON)
    set(BUILD_WITH_STATIC_RUNTIME_LIBS OFF)
else()
    message(FATAL_ERROR "rttr's build system does not support this configuration: VCPKG_LIBRARY_LINKAGE: ${VCPKG_LIBRARY_LINKAGE} VCPKG_CRT_LINKAGE: ${VCPKG_CRT_LINKAGE}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_RTTR_DYNAMIC=${BUILD_RTTR_DYNAMIC}
        -DBUILD_WITH_STATIC_RUNTIME_LIBS=${BUILD_WITH_STATIC_RUNTIME_LIBS}
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/rttr/cmake)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/README.md"
)
