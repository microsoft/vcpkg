vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blitzpp/blitz
    REF 839fc5e0f35b1c38a01cfd7a94e83de81e8a6b55
    SHA512 efb6b19691e23c95cf6abd59607bce299b0c02a12ce6be105a35ad8509ab564b8dac8d6363f048e547d199e117d2bdd0e4ef3046d3c411f669c0a453a0b75627
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blitz/matbops.h" "${SOURCE_PATH}" "" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blitz/matuops.h" "${SOURCE_PATH}" "" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blitz/mathfunc.h" "${SOURCE_PATH}" "" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/blitz/promote-old.h" "${SOURCE_PATH}" "" IGNORE_UNCHANGED)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
