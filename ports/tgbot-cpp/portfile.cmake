vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO reo7sp/tgbot-cpp
    REF "v${VERSION}"
    SHA512 34eac9aac2cbf6025bde24c1a2bdb79b143a18b8fffd81e51340ee3cbb61338b1747e3d54c2d8b0f99e381231756bf11daa4b6ba4da1fd0a1ef40969dee7c647
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DBUILD_DOCUMENTATION=OFF
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        "-DFEATURES=${FEATURES}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TgBot")

file(READ "${CURRENT_PACKAGES_DIR}/share/tgbot-cpp/TgBotConfig.cmake" tgbot_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/tgbot-cpp/TgBotConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Boost COMPONENTS system)
find_dependency(CURL)
${tgbot_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
