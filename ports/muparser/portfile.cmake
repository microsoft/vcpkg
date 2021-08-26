vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beltoforion/muparser
    REF 207d5b77c05c9111ff51ab91082701221220c477 # v2.3.2
    SHA512 75cebef831eeb08c92c08d2b29932a4af550edbda56c2adb6bc86b1228775294013a07d51974157b39460e60dab937b0b641553cd7ddeef72ba0b23f65c52bf4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DENABLE_SAMPLES=OFF
        -DENABLE_OPENMP=OFF
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)