vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SanderMertens/flecs
    REF "v${VERSION}"
    SHA512 d7289610d5a5622e8c04a537131a9db350af92e3d054ce5cd7c931bd3787bcd65135068f25f2e654816674d3ee4bb0653c7f78577527acee6f545beb33032418
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
