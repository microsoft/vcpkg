vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF cares-1_17_2
    SHA512 1111f1e7eeb0e5d9e70d1a7c8566145d0a5e6e71b020f3fcaa02ecdf1931553ddeff83fdc152a1f9c5a780078e8afe3670164b631df56eecd2b638210cc59bb3
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCARES_STATIC=${BUILD_STATIC}
        -DCARES_SHARED=${BUILD_SHARED}
        -DCARES_BUILD_TOOLS=OFF
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_CONTAINER_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/c-ares)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/ares.h
        "#ifdef CARES_STATICLIB" "#if 1"
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin") # Empty folders
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
