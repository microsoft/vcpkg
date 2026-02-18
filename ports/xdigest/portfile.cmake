vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rinrab/xdigest
    REF "${VERSION}"
    SHA512 2a98b29ceaf1d17e9251c1486d03a2d3db133a29fede730ebdf1cb84987aa50781e56ce1db2d795f6dff84b755720b91aa866da662699d34d8a9d140adc8d04e
    HEAD_REF trunk
)

if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR
        VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        vcpkg_find_acquire_program(NASM)
        list(APPEND OPTIONS "-DCMAKE_ASM_NASM_COMPILER=${NASM}")
        set(USE_ASM ON)
    else()
        set(USE_ASM OFF)
    endif()
elseif (VCPKG_TARGET_IS_LINUX)
    if (VCPKG_TARGET_ARCHITECTURE MATCHES "arm64" OR 
        VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR
        VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(USE_ASM ON)
    else()
        set(USE_ASM OFF)
    endif()
elseif (VCPKG_TARGET_IS_OSX)
    set(USE_ASM ON)
else()
    set(USE_ASM OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DUSE_ASM=${USE_ASM}
        ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xdigest")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
