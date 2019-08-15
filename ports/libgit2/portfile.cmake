# libgit2 uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF v0.28.3
    SHA512 15444823b7d4885f7b8c3982f8905efc4a75913de016a9b2e0a24d5ce9746e6a549dffd5469036529557feff2ce7ece9328266eb312c80b96091ce0f65ee97ee
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_CLAR=OFF
        -DSTATIC_CRT=${STATIC_CRT}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgit2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgit2/COPYING ${CURRENT_PACKAGES_DIR}/share/libgit2/copyright)
