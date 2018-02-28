include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v3.0.0
    SHA512 d14ae2b33d832c456621fd0abb137450ae9d7eedf2a3d343a82f2b609da3946e501a9d8016f62b3dd0219a0eaf3c47f82d6023960608d670632939e0b35e8167
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
