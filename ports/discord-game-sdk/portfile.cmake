vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS https://dl-game-sdk.discordapp.net/2.5.6/discord_game_sdk.zip
    FILENAME discord_game_sdk.zip
    SHA512 4c8f72c7bdf92bc969fb86b96ea0d835e01b9bab1a2cc27ae00bdac1b9733a1303ceadfe138c24a7609b76d61d49999a335dd596cf3f335d894702e2aa23406f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES
        include-cstdint.patch # allows compiling on newer versions of GCC
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION ${SOURCE_PATH})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCH_FOLDER "x86")
else(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCH_FOLDER "x86_64")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "discord_game_sdk.lib")
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "discord_game_sdk.lib")
elseif(VCPKG_TARGET_IS_OSX)
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "libdiscord_game_sdk.dylib")
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "libdiscord_game_sdk.dylib")
elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "libdiscord_game_sdk.so")
    file(INSTALL "${SOURCE_PATH}/lib/${ARCH_FOLDER}/discord_game_sdk.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "libdiscord_game_sdk.so")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DSDK_LIB_FOLDER=${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
