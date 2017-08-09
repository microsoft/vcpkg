include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF be6dc3db83c4701e3e79694dcbfd1c3da03b91dd
    SHA512 1e01a925a2c0bab8b9a329d005384e4b620df118317fd8408ea6afdb22278a2710d26b8d51e2ef762798c757a9e01b47db55280ebb84ca290fb88ae5b18d63e3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSNAPPY_BUILD_TESTS=OFF)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Snappy)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(CONF debug release)
        file(READ ${CURRENT_PACKAGES_DIR}/share/snappy/SnappyTargets-${CONF}.cmake CONFIG_FILE)
        string(REPLACE "lib/snappy.dll" "bin/snappy.dll" CONFIG_FILE "${CONFIG_FILE}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/snappy/SnappyTargets-${CONF}.cmake "${CONFIG_FILE}")
    endforeach()
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/snappy.dll ${CURRENT_PACKAGES_DIR}/bin/snappy.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/snappy.dll ${CURRENT_PACKAGES_DIR}/debug/bin/snappy.dll)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/snappy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snappy/COPYING ${CURRENT_PACKAGES_DIR}/share/snappy/copyright)
