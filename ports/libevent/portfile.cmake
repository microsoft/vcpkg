vcpkg_fail_port_install(MESSAGE "${PORT} does not currently support UWP" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KomodoPlatform/libevent
    REF release-2.1.11-stable
    SHA512 a34ca4ad4d55a989a4f485f929d0ed2438d070d0e12a19d90c2b12783a562419c64db6a2603b093d958a75246d14ffefc8730c69c90b1b2f48339bde947f0e02
    PATCHES
        fix-file_path.patch
        fix-LibeventConfig_cmake_in_path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    openssl EVENT__DISABLE_OPENSSL
    thread  EVENT__DISABLE_THREAD_SUPPORT
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBEVENT_LIB_TYPE SHARED)
else()
    set(LIBEVENT_LIB_TYPE STATIC)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(LIBEVENT_STATIC_RUNTIME ON)
else()
    set(LIBEVENT_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DEVENT__LIBRARY_TYPE=${LIBEVENT_LIB_TYPE}
        -DEVENT__MSVC_STATIC_RUNTIME=${LIBEVENT_STATIC_RUNTIME}
        -DEVENT__DISABLE_BENCHMARK=ON
        -DEVENT__DISABLE_TESTS=ON
        -DEVENT__DISABLE_REGRESS=ON
        -DEVENT__DISABLE_SAMPLES=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/libevent/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/event_rpcgen.py ${CURRENT_PACKAGES_DIR}/tools/libevent/event_rpcgen.py)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

set(_target_suffix)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_target_suffix static)
else()
    set(_target_suffix shared)
endif()
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/libevent/LibeventTargets-${_target_suffix}.cmake
    "${CURRENT_PACKAGES_DIR}"
    "${CURRENT_INSTALLED_DIR}"
)

vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
