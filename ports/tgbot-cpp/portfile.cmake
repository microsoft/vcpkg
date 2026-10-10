vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO reo7sp/tgbot-cpp
    REF "v${VERSION}"
    SHA512 7472a953338ad6946a4cf66d8170d34bee331aebc33ff6deae63846de8adc94321a438b14918ca192afbb4214304ae1fc45ecef7f9cee66236b5e1c24ab6135c
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
