include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF 2.1
    SHA512 c20f481ba1bd3f1add2d7ee085db7dfa387e3675df5551e64bf294a96f4902551635e83faf2580fb0d6a55fd5ed1c906510d6cb39580a07234e5638e6c747fe0
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ST_BUILD_STATIC ON)
else()
    set(ST_BUILD_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DST_BUILD_STATIC=${ST_BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/string_theory)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory ${CURRENT_PACKAGES_DIR}/share/string_theory)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/string-theory)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory/LICENSE ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright)
file(COPY ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/string_theory/copyright)
