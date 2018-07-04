if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
    message("tinyobjloader doesn't support dynamic linkage on Windows. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader
    REF 8fd9f6e57bf8c70d5ae47cf0f0d1bf1ccae2dfc2
    SHA512 5b6a2822989c5a28eabee0a33724c045b5d07cf0ccfd4288c7c3a5a2cc5b0c3f6ee8aca45e8e22c941278fbbfabd8f909f5010cd34b9d905c4d84102d151c73b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TINYOBJLOADER_COMPILATION_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DTINYOBJLOADER_COMPILATION_SHARED=${TINYOBJLOADER_COMPILATION_SHARED}
        -DCMAKE_INSTALL_DOCDIR:STRING=share/tinyobjloader
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/tinyobjloader/cmake)

file(
    REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/tinyobjloader
    ${CURRENT_PACKAGES_DIR}/debug/lib/tinyobjloader
)

vcpkg_copy_pdbs()

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/copyright)
