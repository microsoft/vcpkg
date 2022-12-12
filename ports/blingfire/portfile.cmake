vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/BlingFire
    REF 7aad1df5f3625de70a760edcb8e54c5d2a65e8a8
    SHA512 c7f039728b72b33d2d66c75d7ca4baaa65fdf797cca99b43c0d9097531f7519302bc7597f5edcd9e1bde537d5f14c78c93a37eb3469f8da72e5bd5c634744301
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
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