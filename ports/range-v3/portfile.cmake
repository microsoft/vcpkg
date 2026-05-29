if(EXISTS "${CURRENT_INSTALLED_DIR}/share/range-v3-vs2015/copyright")
    message(FATAL_ERROR "'${PORT}' conflicts with 'range-v3-vs2015'. Please remove range-v3-vs2015:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ericniebler/range-v3
    REF a81477931a8aa2ad025c6bda0609f38e09e4d7ec # Dude, where's my bored ape? (0.12.0)
    SHA512 e58030bc7c281e90298025dc21fed9bdabda358cd847b59e5b58feb3e0b93fcf6398e3b8e2912e45deeed67f454c08d4fc4df7f8d0dc378b437612f15c0832fe
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRANGE_V3_TESTS=OFF
        -DRANGE_V3_EXAMPLES=OFF
        -DRANGE_V3_PERF=OFF
        -DRANGE_V3_HEADER_CHECKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/range-v3)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/include/module.modulemap"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
