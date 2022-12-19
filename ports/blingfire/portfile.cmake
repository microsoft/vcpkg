vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/BlingFire
    REF 5089d31914cbed7a24589e753bd6cd362a377fbb
    SHA512 428fbcd4fa695715c4ca299e314a85adb12bc41ab21eb373aa800d4ccb8755361b87b6c8d64e392922fd9cc334f5353fe638d2c3b1b61ab9d4cfdd94b6c36074
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")