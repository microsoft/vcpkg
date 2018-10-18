# libgit2 uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF v0.27.4
    SHA512 d27db86eb1b9f0d4057f8538ba1985ee76c3ca106e57d417fa9bff79d575f91a07ad28693112b58dc1d61d68116a82e6a145f12276158f2806b6c4964d741f61
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
