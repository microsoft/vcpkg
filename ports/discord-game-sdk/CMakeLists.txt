cmake_minimum_required(VERSION 3.5)

project(discord_game_sdk_cpp)

find_library(SDK_LIB
    NAMES "discord_game_sdk" "discord_game_sdk.dll"
    PATHS "${PROJECT_SOURCE_DIR}/lib/${ARCH_FOLDER}"
    NO_DEFAULT_PATH
)

file(GLOB SRC_FILES "${PROJECT_SOURCE_DIR}/cpp/*.cpp")
file(GLOB_RECURSE HDR_FILES "${PROJECT_SOURCE_DIR}/*.h")

add_library(discord_game_sdk_cpp STATIC ${SRC_FILES})
target_link_libraries(discord_game_sdk_cpp PUBLIC ${SDK_LIB})

install(TARGETS discord_game_sdk_cpp ARCHIVE)
install(FILES ${HDR_FILES} DESTINATION "include/discord-game-sdk")