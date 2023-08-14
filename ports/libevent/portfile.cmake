vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevent/libevent
    REF 4d85d28acdbb83bb60e500e9345bab757b64d6d1
    SHA512 d03daf8e2277e8b9d67e0028d05566c8972a706e53dcb6593f8f92942ff9ce814970418a10d4c37e68228ec153f8fbc7d764a7ff92e2872277a92039380cbbe9
    PATCHES
        fix-uwp.patch
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

if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DEVENT__HAVE_AFUNIX_H=0)
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
        -DEVENT__DISABLE_MBEDTLS=ON
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
