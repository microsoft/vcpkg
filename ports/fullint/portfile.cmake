vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO denis-king/FullInt
    REF "v${VERSION}"
    SHA512 1ec2140efd3acdb5a06b298f1711bbf76aeea05a561145d65bbac9d5c45d146a2924451065105804f1153ce83315816b59abed98c4b999424b76fc76631bb51f
    HEAD_REF master
)

# a static library: the assembly kernels are linked into it
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    # the x86 / x64 kernels are NASM sources
    vcpkg_find_acquire_program(NASM)
    list(APPEND options "-DCMAKE_ASM_NASM_COMPILER=${NASM}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/FullInt.Cpp"
    OPTIONS
        ${options}
        -DFULLINT_INSTALL=ON
        -DFULLINT_BUILD_TOOLS=OFF
        -DFULLINT_WITH_GMP=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FullInt)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
