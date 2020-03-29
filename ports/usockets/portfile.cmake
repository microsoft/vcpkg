IF (NOT VCPKG_TARGET_IS_LINUX)
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF 929242ce5223115093e83683524cb4d7384c7868 # v0.3.5
    SHA512 3de7e11223bc0a47de1ec9aea7822a5753d65eda0a4ff8f9893c5e4b103a3c7e48ab159ecce23bea5a0ee7dbba1a5975e32ccb7f7ca7cddff120b3020159aef9
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if ("network" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature network only support Windows")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ssl CMAKE_USE_OPENSSL
    event CMAKE_USE_EVENT
    network CMAKE_USE_NETWORK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DLIBUS_USE_LIBUV=${USE_LIBUV}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()