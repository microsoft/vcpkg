vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NTNU-IHB/FMI4cpp
    REF 0.8.0
    SHA512 547f61dfbd57593ff8839fbed3f8a5624551ee4be5e0dd7773384a869086af8a4483cfe17dc087e3f03c9ea2038b537c8c4998a405687c1a353d08e52dac411e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMI4CPP_BUILD_TESTS=OFF
        -DFMI4CPP_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
