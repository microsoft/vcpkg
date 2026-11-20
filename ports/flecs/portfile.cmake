vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SanderMertens/flecs
    REF "v${VERSION}"
    SHA512 875afea913247fe40a812bfd570e9091280e356f760e57d9aa02d93af1478e307650f5c4fcaf7938eec729b46aa82d9f845d5591a3b3956f9c70a087349e7a69
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" FLECS_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" FLECS_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLECS_STATIC=${FLECS_STATIC_LIBS}
        -DFLECS_SHARED=${FLECS_SHARED_LIBS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(FLECS_STATIC_LIBS)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/${PORT}/bake_config.h"
        "#ifndef flecs_STATIC"
        "#if 0 // #ifndef flecs_STATIC"
    )
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
    COMMENT [[
Beyond the main MIT LICENSE, some compiled sources bundle third-party notices:
  src/addons/http/http.c        EmbeddableWebServer (BSD-2-Clause)
  src/datastructures/hash.c     wyhash (Unlicense / public domain)
  src/datastructures/strbuf.c   stm32tpl float formatting (Anton B. Gusev)
]]
)
