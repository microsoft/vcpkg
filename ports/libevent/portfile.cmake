vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevent/libevent
    REF release-2.1.12-stable
    SHA512 5d6c6f0072f69a68b190772d4c973ce8f33961912032cdc104ad0854c0950f9d7e28bc274ca9df23897937f0cd8e45d1f214543d80ec271c5a6678814a7f195e
    PATCHES
        fix-file_path.patch
        fix-LibeventConfig_cmake_in_path.patch
        fix-usage.patch
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DEVENT__LIBRARY_TYPE=${LIBEVENT_LIB_TYPE}
        -DEVENT__MSVC_STATIC_RUNTIME=${LIBEVENT_STATIC_RUNTIME}
        -DEVENT__DISABLE_BENCHMARK=ON
        -DEVENT__DISABLE_TESTS=ON
        -DEVENT__DISABLE_REGRESS=ON
        -DEVENT__DISABLE_SAMPLES=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/libevent/")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/event_rpcgen.py" "${CURRENT_PACKAGES_DIR}/tools/libevent/event_rpcgen.py")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
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
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/libevent/LibeventConfig.cmake "${SOURCE_PATH}/include;${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/include" "")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
