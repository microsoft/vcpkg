vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bobjen/spookyhash
    REF c3bbfb644c4e7d07f4f2eaceb0dc329784defdeb
    SHA512 8e755f5bd3d9869533f55a84825609c903892fd1cc029cd85cfde1b165614675baeb15887b30cf091a43f3f1e0fa466a9d4215fad359e8789d1ccb28bd5732ec
    HEAD_REF main
)

configure_file("${CURRENT_PORT_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)
configure_file("${CURRENT_PORT_DIR}/unofficial-spookyhash-config.cmake.in" "${SOURCE_PATH}/unofficial-spookyhash-config.cmake.in" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPOOKYHASH_VERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-spookyhash CONFIG_PATH lib/cmake/unofficial-spookyhash)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage-accurate")
