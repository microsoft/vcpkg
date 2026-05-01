vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tomh500/SteamHelper
    REF 1.0.1
    SHA512  e689df4340cd5d80f277109eabb33a6ecc5541be7525361ba7ed93f37b14f76cd8c4faee790937d8403eb4af81f50182aad3aa5643b4f5c1e6adec836c886000
    HEAD_REF main
)


vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA # 提高编译速度
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(GLOB_RECURSE LICENSE_FILE "${SOURCE_PATH}/LICENSE*")

if(LICENSE_FILE)
    file(INSTALL "${LICENSE_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    message(FATAL_ERROR "Could not find LICENSE file in ${SOURCE_PATH}")
endif()