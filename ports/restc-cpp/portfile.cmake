# only static library is available
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaa/restc-cpp
    REF v0.10.0
    SHA512 0f74d825d3958810c270748c2810953fe394d0bf1f147d81b9177803e29a86c702715d5995c5966c4fe671b7689f26d9a0fad4e82d111277bbd3ddce1a68f73a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cxx17         RESTC_CPP_USE_CPP17
    boost-log     RESTC_CPP_LOG_WITH_BOOST_LOG
    clog          RESTC_CPP_LOG_WITH_CLOG
    openssl       RESTC_CPP_WITH_TLS
    zlib          RESTC_CPP_WITH_ZLIB
    threaded-ctx  RESTC_CPP_THREADED_CTX
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW
        -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$$<$$<CONFIG:Debug>:Debug>
        -DINSTALL_RAPIDJSON_HEADERS=OFF
        -DRESTC_CPP_WITH_EXAMPLES=OFF
        -DRESTC_CPP_WITH_UNIT_TESTS=OFF
        -DRESTC_CPP_WITH_FUNCTIONALT_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT} TARGET_PATH share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
