IF (NOT VCPKG_TARGET_IS_LINUX)
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF 5440dbac79bd76444175b76ee95dfcade12a6aac # 0.7.1
    SHA512 d4827982a288c81edfcb167cfa6ee8fe11bbae90d25ed9086c006cf6098dfad8b6b910f8fb93ecc67fbea76452627dd4666c7ae3d74fb20112f8e22f7091ec11
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
