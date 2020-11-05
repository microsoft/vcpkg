#https://github.com/google/benchmark/issues/661
vcpkg_fail_port_install(ON_TARGET "uwp") 

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF 73d4d5e8d6d449fc8663765a42aa8aeeee844489 # v1.5.2
    SHA512 b87a7c207eb85187165df8ff99ab1bbf5d38fc2a6d839e267a71987951c94e33b55fd7fbee6f2b59202b0379a7e9705b73b193edaea0b9c742eddf3fcbe5f48e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)