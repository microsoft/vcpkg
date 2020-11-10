vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/dav1d
    REF 0.7.1
    SHA512 355a021df537f24b39e54ca77c167cdebe1c6739a1f97500ceb522526b9d1fb51aeee8d8c729ed14907c5796de8a99a0e83ac306182f8cef5be90d3b5aec7b37
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

set(LIBRARY_TYPE ${VCPKG_LIBRARY_LINKAGE})
if (LIBRARY_TYPE STREQUAL "dynamic")
    set(LIBRARY_TYPE "shared")
endif(LIBRARY_TYPE STREQUAL "dynamic")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --default-library=${LIBRARY_TYPE}
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
