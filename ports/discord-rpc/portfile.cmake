include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v3.1.0
    SHA512 f467ac6428588b45a90eaec0786b7f0d799b5ee9e97528dd69cd1890fb4dd9c887807e845a0a1d75e19e6e1f6cb2d21c8a77d09e95f24d8df0aae04eae17a216
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
