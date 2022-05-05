vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO magiblot/tvision
    REF 638f963fe4f6c84854f60f1e9c5772bf6603e4b2
    HEAD_REF master
    SHA512 87c26fed26a332dd4b2a431dfbe0f8629d6565c59f61a3968fc658beda313ee8dad9bb59f53d47b1d664c0494841850b09e5c05533b2a74a372cc03548def2c5
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTV_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
