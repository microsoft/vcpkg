vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.4.1/sentry-native.zip"
    FILENAME "sentry-native-0.4.1.zip"
    SHA512 644e18e89e63c21f7aef9fd389ae768e4f4951ba970d52c529782391e8acb47cb49136dabc156365bdfa13cdd1bd21745d486f836bb21c88f282bd1a533e6420
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if (NOT DEFINED SENTRY_BACKEND)
    if(MSVC AND CMAKE_GENERATOR_TOOLSET MATCHES "_xp$")
        set(SENTRY_BACKEND "breakpad")
    elseif(APPLE OR WIN32)
        set(SENTRY_BACKEND "crashpad")
    elseif(LINUX)
        set(SENTRY_BACKEND "breakpad")
    else()
        set(SENTRY_BACKEND "inproc")
    endif()
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    set(SENTRY_NATIVE_C_STANDARD 99)
else()
    set(SENTRY_NATIVE_C_STANDARD 11)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSENTRY_BUILD_TESTS=OFF
        -DSENTRY_BUILD_EXAMPLES=OFF
        -DCMAKE_C_STANDARD=${SENTRY_NATIVE_C_STANDARD}
        -DSENTRY_BACKEND=${SENTRY_BACKEND}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sentry TARGET_PATH share/sentry)

if (WIN32 AND SENTRY_BACKEND STREQUAL "crashpad")
    vcpkg_copy_tools(
        TOOL_NAMES crashpad_handler
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
