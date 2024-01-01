if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

set(PATCHES "")
if(VCPKG_TARGET_IS_WINDOWS)
    #vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Meson is not able to automatically export symbols for DLLs
    set(PATCHES fix_msvc_build.patch 
                build.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xkbcommon/libxkbcommon
    REF 57af9cb71f19f37394399b549f7cb7b0d9fe3988 # v 1.4.1
    SHA512  0f1ecdf12c3cc6ff547a9cf42aa8ce1c63acbf2f6fb766899e5e8dbda401e25dd8137c2f59a04dadd445b4873bb80b8ae8b23f88140e5a318186c308a65921f5
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS -Denable-xkbregistry=false)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Denable-wayland=false
        -Denable-docs=false
        -Denable-tools=false
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
