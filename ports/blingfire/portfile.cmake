vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/BlingFire
    REF c0381c68b6aa6d1b4e569888bae1642e40494a99
    SHA512 0fa15791fc815a992023bae6f30c84dda1d477bcdedcf1343d4dbe4b09b51e17fd87bf130d58e50f378ca94982a6306d7f980e3ff4522091be036428684bdcbb
    HEAD_REF master
    PATCHES
        ninja.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${ADDITIONAL_OPTIONS}
    )

vcpkg_cmake_install()

file(GLOB BINS "${SOURCE_PATH}/nuget/lib/*.bin")

foreach(BIN ${BINS})
    file(INSTALL "${BIN}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")