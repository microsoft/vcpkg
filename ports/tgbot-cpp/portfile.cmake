vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO reo7sp/tgbot-cpp
    REF "v${VERSION}"
    SHA512 34eac9aac2cbf6025bde24c1a2bdb79b143a18b8fffd81e51340ee3cbb61338b1747e3d54c2d8b0f99e381231756bf11daa4b6ba4da1fd0a1ef40969dee7c647
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "disable-nagles"      TGBOT_DISABLE_NAGLES_ALGORITHM
        "expand-read"         TGBOT_CHANGE_READ_BUFFER_SIZE
        "expand-socket"       TGBOT_CHANGE_SOCKET_BUFFER_SIZE
)

if(TGBOT_DISABLE_NAGLES_ALGORITHM)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        [[add_library(${PROJECT_NAME} ${SRC_LIST})]]
        [[add_library(${PROJECT_NAME} ${SRC_LIST})
target_compile_definitions(${PROJECT_NAME} PRIVATE TGBOT_DISABLE_NAGLES_ALGORITHM)]])
endif()

if(TGBOT_CHANGE_READ_BUFFER_SIZE)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        [[add_library(${PROJECT_NAME} ${SRC_LIST})]]
        [[add_library(${PROJECT_NAME} ${SRC_LIST})
target_compile_definitions(${PROJECT_NAME} PRIVATE TGBOT_CHANGE_READ_BUFFER_SIZE)]])
endif()

if(TGBOT_CHANGE_SOCKET_BUFFER_SIZE)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        [[add_library(${PROJECT_NAME} ${SRC_LIST})]]
        [[add_library(${PROJECT_NAME} ${SRC_LIST})
target_compile_definitions(${PROJECT_NAME} PRIVATE TGBOT_CHANGE_SOCKET_BUFFER_SIZE)]])
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DBUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TgBot")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
