# libgit2 uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF b3e1a56ebb2b9291e82dc027ba9cbcfc3ead54d3
    SHA512 0879c162e2e1dc00eadfbda22cd1f9d3a95b4ec2b653c108983f37c2f695140882de4d50d7cbc04ced247125a4e9fe6df16130e1267891aecdb2411d920db5c6
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
