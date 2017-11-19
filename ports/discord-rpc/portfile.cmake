include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v2.0.1
    SHA512 496f8f34184c4be3c3341b05ebd440a9e89e36ecf15747ea8f4d1cc0404f1341404fda6c8358a2c08e0149023775472ea78603b9d41687f1004828523debda99
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH
        ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-debug.diff
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_DYNAMIC_LIB ON)
else()
    set(BUILD_DYNAMIC_LIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DBUILD_DYNAMIC_LIB=${BUILD_DYNAMIC_LIB}
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
