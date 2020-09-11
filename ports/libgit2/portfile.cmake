# libgit2 uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF 0ced29612dacb67eefe0c562a5c1d3aab21cce96#version 1.0.1
    SHA512 477e7309682d470965ef85c84f57b647526e1d2cd9ece1fd4f5f4e03e586280651ee40aafadb5b66940cfbd80816f205aa54886f457ca8fd795313137e015102
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

if ("pcre" IN_LIST FEATURES)
    set(REGEX_BACKEND pcre)
elseif ("pcre2" IN_LIST FEATURES)
    set(REGEX_BACKEND pcre2)
else()
    set(REGEX_BACKEND builtin)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_CLAR=OFF
        -DREGEX_BACKEND=${REGEX_BACKEND}
        -DSTATIC_CRT=${STATIC_CRT}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
