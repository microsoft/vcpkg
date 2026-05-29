vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/generator
    REF a8e421f04159199f6896b09cad2bd3c6fbb2a5fb
    SHA512 bb00cc0b3224813c7837175d81d7a08627dfe7a2f52c0bb8125ec7c6e8018a0a856c94463105dd04e7e20b8af9afc57c1c7228e9119174a9e621e675f8a3b447
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGENERATOR_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
