cmake_minimum_required(VERSION 3.5)

project(discord_game_sdk_cpp)

find_library(SDK_LIB
    "discord_game_sdk"
    PATHS "${SDK_LIB_FOLDER}"
    NO_DEFAULT_PATH
)

file(GLOB SRC_FILES "${PROJECT_SOURCE_DIR}/cpp/*.cpp")
file(GLOB_RECURSE HDR_FILES "${PROJECT_SOURCE_DIR}/*.h")

add_library(discord_game_sdk_cpp STATIC ${SRC_FILES})
target_link_libraries(discord_game_sdk_cpp PUBLIC ${SDK_LIB})
set_property(TARGET discord_game_sdk_cpp PROPERTY CXX_STANDARD 11)

install(TARGETS discord_game_sdk_cpp ARCHIVE)
install(FILES ${HDR_FILES} DESTINATION "include/discord-game-sdk")