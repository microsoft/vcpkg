include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v2.1.0
    SHA512 24bbc391670bfb53f0501ed189cef8193f35332de9fff3016fc18eb7eab4970d5c90576aa95dfcc4f1ef553e8b1ea781e1e40e595cbbcc1c4200e4ff174369de
    HEAD_REF master
)

set(STATIC_CRT OFF)
if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_CRT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DUSE_STATIC_CRT=${STATIC_CRT}
)

vcpkg_install_cmake()

# Remove bin and debug include
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/send-presence.exe
                ${CURRENT_PACKAGES_DIR}/debug/bin/send-presence.exe)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/discord-rpc" RENAME "copyright")

vcpkg_copy_pdbs()
