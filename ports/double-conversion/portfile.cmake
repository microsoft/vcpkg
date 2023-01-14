vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF af09fd65fcf24eee95dc62813ba9123414635428 #v3.2.1
    SHA512 721d736a2d065b8ff6058345afe6990ab568174e202361abc7ce36c16931c05128df4fd5034f98f114a7b01972eda3b98bfc209ef45394d0b5d4bbce8140b28a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Rename exported target files into something vcpkg_fixup_cmake_targets expects
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
