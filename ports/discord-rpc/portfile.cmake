include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v3.3.0
    SHA512 8bb2674edefabf75670ceca29364d69e2002152bff9fe55757f4cda03544b4d827ff33595d98e6d8acdc73ca61cef8ab8054ad0a1ffc905cb26496068b15025f
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
