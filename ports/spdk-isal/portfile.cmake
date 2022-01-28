
vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO spdk/isa-l
        REF spdk
        SHA512 1d170ed050fb612816c77b3586f1cdce9129eedc559e3fcefc983ede05b6c8e13a52e400ee6935f5da6ab045a899c97f6ed6be3a79691284e211ea8a6d697f7c
        HEAD_REF master
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path("${NASM_PATH}")

vcpkg_find_acquire_program(YASM)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/spdk-isalConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
