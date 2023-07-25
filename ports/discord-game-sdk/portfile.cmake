vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS https://dl-game-sdk.discordapp.net/3.2.1/discord_game_sdk.zip
    FILENAME discord_game_sdk.zip
    SHA512 4851cb70f428eb391959018aa7206e11232348189f7e47f9b8e15535f02a8b114ef825198b0d772979b77ca47061ee7fa764ca90a1dc39370eb9802e8bf04541
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        include-cstdint.patch # allows compiling on newer versions of GCC
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCH_FOLDER "x86")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCH_FOLDER "x86_64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(ARCH_FOLDER "aarch64")
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DSDK_LIB_FOLDER=${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
