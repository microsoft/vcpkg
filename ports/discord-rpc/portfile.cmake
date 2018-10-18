include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO discordapp/discord-rpc
    REF v3.3.0
    SHA512 8bb2674edefabf75670ceca29364d69e2002152bff9fe55757f4cda03544b4d827ff33595d98e6d8acdc73ca61cef8ab8054ad0a1ffc905cb26496068b15025f
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)
file(REMOVE_RECURSE ${SOURCE_PATH}/thirdparty)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_STATIC_CRT=${STATIC_CRT}
        -DBUILD_EXAMPLES=OFF
        -DRAPIDJSONTEST=TRUE
        -DRAPIDJSON=${CURRENT_INSTALLED_DIR}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/discord-rpc" RENAME "copyright")

vcpkg_copy_pdbs()
