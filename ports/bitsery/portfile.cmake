vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraillt/bitsery
    REF c0fc083c9de805e5825d7553507569febf6a6f93 # v5.2.2
    SHA512 a4c8660f6e8dcb5162f6f75e0f1e4716032b8403e9461f42e0628955eb07dc7c17aec9f774f45c2c15cce28a231699a71815d3d6d7d0f34a1367ee1e2d944305
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
