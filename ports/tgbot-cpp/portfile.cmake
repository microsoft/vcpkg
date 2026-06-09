vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO reo7sp/tgbot-cpp
    REF "v${VERSION}"
    SHA512 0ee6b7658894697ccc38fbf0f7d0b0ca80d9af2a86cec5c78cd5501e472fed8d2aa351364bb7d5a4860c73df9916a82879d9fdfd90e7accfe180ef679e1dcdfd
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
