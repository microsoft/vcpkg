vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinh/libconfuse
    REF 67e1207c8de440525a3fdde1448a586791ebc052
    SHA512 15d4eb0640fe74cc90910820715a70b2f944d2ed9753cca3be90f0ac6840beeda6a370b0624588d81ed2def2f8463e404473721351a685af711cf1d59efb870a
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/confuse.h
        "ifdef BUILDING_STATIC"
        "if 1 // ifdef BUILDING_STATIC"
    )
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_fixup_pkgconfig()
