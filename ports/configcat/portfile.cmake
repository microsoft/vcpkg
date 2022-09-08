vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO configcat/cpp-sdk
    REF v0.1.0
    SHA512 9ff25ce3d731305b6618e8d5837302db4048b3cd93e15624fbeecf052f8377ab88ff07f8f765fe64abc1a7cf1d25bd6d8dfd37955cdfaac0acee8d542e31562c
    HEAD_REF semver
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCONFIGCAT_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
