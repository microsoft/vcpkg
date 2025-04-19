vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF v${VERSION}
    SHA512 968288f466bb8174f59de1935b0958a5d996a7838c816032977662ef6425254ab073104c133c8bdf6efd017c4fcc847e2285379e148156fdeb1d74970a603698
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

# disable docs
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(doc)" "")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "include(linting_target)" "")

# do not enable LTO by default
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)" "")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        diagnostics UA_ENABLE_DIAGNOSTICS
        discovery UA_ENABLE_DISCOVERY
        historizing UA_ENABLE_HISTORIZING
        methodcalls UA_ENABLE_METHODCALLS
        subscriptions UA_ENABLE_SUBSCRIPTIONS
        subscriptions-events UA_ENABLE_SUBSCRIPTIONS_EVENTS
)

if("openssl" IN_LIST FEATURES)
    set(OPEN62541_ENCRYPTION_OPTIONS -DUA_ENABLE_ENCRYPTION=OPENSSL)
    if("mbedtls" IN_LIST FEATURES)
        message(WARNING "Only one encryption method can be used. When both [openssl] and [mbedtls] "
            "are on, openssl is used. To use [mbedtls], don't enable [openssl]. To suppress this "
            "message, don't enable [mbedtls]")
    endif()
elseif("mbedtls" IN_LIST FEATURES)
    set(OPEN62541_ENCRYPTION_OPTIONS -DUA_ENABLE_ENCRYPTION=MBEDTLS)
endif()

if("multithreading" IN_LIST FEATURES)
    set(OPEN62541_MULTITHREADING_OPTIONS -DUA_MULTITHREADING=100)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${OPEN62541_ENCRYPTION_OPTIONS}
        ${OPEN62541_MULTITHREADING_OPTIONS}
        "-DOPEN62541_VERSION=v${VERSION}"
        -DUA_ENABLE_DEBUG_SANITIZER=OFF
        -DUA_MSVC_FORCE_STATIC_CRT=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/open62541")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/open62541/tools")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
