# libgit2 uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF 7d3c7057f0e774aecd6fc4ef8333e69e5c4873e0#version 1.0.0
    SHA512 bc1792052da87974c4c106ad2c9825b7b172da9829697205fa3032f394e24ac8354798db4cbe28ac55b1e565ecfb3d655c63fad90f53f0c291bf591a458f2cf8
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
