vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/dav1d
    REF 99172b11470776177939c3d2bc366fe8d904eab7  #v1.0.0
    SHA512 8ab32d7f1e7ec0fb2aae9ae19e199f7a6b17f88af2287c13a9ca577f80f02351e601fb6c6f03c9505d6cecd047b823007ffef83a5ca3703e4d2a4dd5ff6d5d3b
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_find_acquire_program(GASPREPROCESSOR)
        foreach(GAS_PATH ${GASPREPROCESSOR})
            get_filename_component(GAS_ITEM_PATH ${GAS_PATH} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH}${VCPKG_HOST_PATH_SEPARATOR}${GAS_ITEM_PATH}")
        endforeach(GAS_PATH)
    endif()
endif()

set(LIBRARY_TYPE ${VCPKG_LIBRARY_LINKAGE})
if (LIBRARY_TYPE STREQUAL "dynamic")
    set(LIBRARY_TYPE "shared")
endif(LIBRARY_TYPE STREQUAL "dynamic")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --default-library=${LIBRARY_TYPE}
        -Denable_tests=false
        -Denable_tools=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
