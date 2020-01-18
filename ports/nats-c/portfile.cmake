# if("streaming" IN_LIST FEATURES)
#     vcpkg_fail_port_install(MESSAGE "${PORT}[streaming] currently only supports Unix" ON_TARGET "Windows")
# endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nats-io/nats.c
    REF v2.1.0
    SHA512 628e14d786e870c3c2de859d060cc035b57c75fa81e16e0eb2b88eb8e7d80762b650e733a45eeb6d4344e754f1440e260e81da91c2ad7ea586087d3647fcefdb
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tls NATS_BUILD_WITH_TLS
    streaming NATS_BUILD_STREAMING
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DNATS_BUILD_TLS_USE_OPENSSL_1_1_API=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/nats.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/nats.dll)
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/nats.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/nats.dll)
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
