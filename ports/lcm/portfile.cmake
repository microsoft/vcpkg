include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF 82bd3a223e3227c70832307e53a65c13c1e5f81b
    SHA512 5d3abf457e18a3bb50489ed17393c5416a459134f73c264e67d174a29411d6deb70c754b5669422a438ea3e5793b9b1b91d67e9d842151c5a910245fede5879f
    HEAD_REF master
)

vcpkg_configure_cmake(
     SOURCE_PATH ${SOURCE_PATH}
     PREFER_NINJA
     OPTIONS
        -DLCM_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/aclocal)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/java)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)

file(COPY ${CURRENT_PACKAGES_DIR}/bin/lcm-gen.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/lcm)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lcm)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lcm RENAME copyright)
