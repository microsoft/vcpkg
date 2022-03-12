vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zerotier/libzt
    REF 41eb9aebc80a5f1c816fa26a06cefde9de906676
    SHA512 97454ef1177a71bb5b15794a71b7dd22a0edb03f4210fe3777beee4cb1476e64a0c99b9593aee8600a82b6b833f1096ce54992e9da148b9ad14c2bc54d6c055c
    HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH ZEROTIERONE_SOURCE_PATH
        REPO zerotier/ZeroTierOne
        REF eac56a2e25bbd27f77505cbd0c21b86abdfbd36b
        SHA512 354d35476d9cfc3d35c8b857d7314c4f2a2842cb2f5e6969de49cb127dc9d9825c2da95930cd2dc5ffc054d08369ee3bcfe9ea570c2c9e3ad1a328722847657f
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH LWIP_SOURCE_PATH
        REPO joseph-henry/lwip
        REF 32708c0a8b140efb545cc35101ee5fdeca6d6489
        SHA512 6562288a734a8ef08cc0db17a4c0766526a0111996f23ea5d417c7973a051b7d4cea6cbd65afef034af3fbc9c9edf143b371cec92c3eff14f46d085125aae43b
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH LWIP_CONTRIB_SOURCE_PATH
        REPO joseph-henry/lwip-contrib
        REF 4fd612c9c72dfcd1db6618bd59c1a17d9f5b55f8
        SHA512 50ac84581557a0a07a1ac9bcdcb10ae023cccc70c54a6dbe698836e6e6c58d694c84ac07106771c93d903c3240a2c7b6da11c24a0da6e4918aeeedb177df611e
        HEAD_REF master
)

file(COPY ${ZEROTIERONE_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ext/ZeroTierOne)
file(COPY ${LWIP_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ext/lwip)
file(COPY ${LWIP_CONTRIB_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ext/lwip-contrib)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_HOST_SELFTEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-libzt-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-libzt/unofficial-libzt-config.cmake" @ONLY)

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

