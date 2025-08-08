vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF "${VERSION}"
    SHA512 f9a84d60198f69ecea477e1a63c635674cac4952c9897586f85f4e2a6e9445de09cf9736cd51e274a29a24d2ec8eb1a0d00b9cc0caa55839a205790e261f29af
    HEAD_REF master
    PATCHES
        dependencies.patch
        ffmpeg.diff
        install-layout.patch
        windows-linkage.patch
)
file(WRITE "${SOURCE_PATH}/.source_version" "${VERSION}-vcpkg")
file(WRITE "${SOURCE_PATH}/CMakeCPack.cmake" "")

if("x11" IN_LIST FEATURES)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libxfixes-dev\n")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        client      WITH_CLIENT
        ffmpeg      WITH_DSP_FFMPEG
        ffmpeg      WITH_FFMPEG
        ffmpeg      WITH_SWSCALE
        server      WITH_SERVER
        urbdrc      CHANNEL_URBDRC
        winpr-tools WITH_WINPR_TOOLS
        x11         WITH_X11
        x11         VCPKG_LOCK_FIND_PACKAGE_X11
)

if("client" IN_LIST FEATURES)
    # Xcode dependency and untested installation paths
    if(VCPKG_TARGET_IS_IOS)
        message(STATUS "Not building native client components.")
        list(APPEND FEATURE_OPTIONS -DWITH_CLIENT_IOS=OFF)
    elseif(VCPKG_TARGET_IS_OSX)
        message(STATUS "Not building native client components.")
        list(APPEND FEATURE_OPTIONS -DWITH_CLIENT_MAC=OFF)
    endif()
endif()

if("server" IN_LIST FEATURES)
    # actual shadow platform subsystem
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS # implementation unmaintained
       OR NOT WITH_X11) # dependency
        list(APPEND FEATURE_OPTIONS -DWITH_SHADOW_SUBSYSTEM=OFF)
    endif()
    # actual platform server implementation
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS) # implementation unmaintained
        list(APPEND FEATURE_OPTIONS -DWITH_PLATFORM_SERVER=OFF)
    endif()
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${GENERATOR_OPTION}
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DCMAKE_REQUIRE_FIND_PACKAGE_cJSON=ON
        -DUSE_VERSION_FROM_GIT_TAG=OFF
        -DWITH_ABSOLUTE_PLUGIN_LOAD_PATHS=OFF
        -DWITH_AAD=ON
        -DWITH_CCACHE=OFF
        -DWITH_CLANG_FORMAT=OFF
        -DWITH_MANPAGES=OFF
        -DWITH_OPENSSL=ON
        -DWITH_SAMPLE=OFF
        -DWITH_UNICODE_BUILTIN=ON
        "-DMSVC_RUNTIME=${VCPKG_CRT_LINKAGE}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        # Unmaintained
        -DWITH_CLIENT_WINDOWS=OFF
        -DWITH_WAYLAND=OFF
        # Uncontrolled dependencies w.r.t. vcpkg ports, system libs, or tools
        # Can be overriden in custom triplet file
        -DUSE_UNWIND=OFF
        -DWITH_ALSA=OFF
        -DWITH_CAIRO=OFF
        -DWITH_CLIENT_SDL=OFF
        -DWITH_CUPS=OFF
        -DWITH_FUSE=OFF
        -DWITH_KRB5=OFF
        -DWITH_LIBSYSTEMD=OFF
        -DWITH_OPUS=OFF
        -DWITH_OSS=OFF
        -DWITH_PCSC=OFF
        -DWITH_PKCS11=OFF
        -DWITH_PROXY_MODULES=OFF
        -DWITH_PULSE=OFF
        -DWITH_URIPARSER=OFF
    OPTIONS_RELEASE
        -DWITH_VERBOSE_WINPR_ASSERT=OFF
    MAYBE_UNUSED_VARIABLES
        MSVC_RUNTIME
        WITH_CLIENT_WINDOWS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_list(SET tools)
if("client" IN_LIST FEATURES AND "x11" IN_LIST FEATURES)
    list(APPEND tools xfreerdp)
endif()
if("server" IN_LIST FEATURES)
    list(APPEND tools freerdp-proxy freerdp-shadow-cli)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Proxy3 PACKAGE_NAME freerdp-Proxy3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Server3 PACKAGE_NAME freerdp-server3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Shadow3 PACKAGE_NAME freerdp-shadow3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rdtk0 PACKAGE_NAME rdtk0 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if("winpr-tools" IN_LIST FEATURES)
    list(APPEND tools winpr-hash winpr-makecert)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WinPR-tools3 PACKAGE_NAME winpr-tools3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Client3 PACKAGE_NAME freerdp-client3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WinPR3 PACKAGE_NAME winpr3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP3 PACKAGE_NAME freerdp)

if(tools)
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/winpr3/winpr/build-config.h" "\"${CURRENT_PACKAGES_DIR}" "/* vcpkg redacted */ \"")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # They build static with dllexport, so it must be used with dllexport. Proper fix needs invasive patching.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp3/freerdp/api.h" "#ifdef FREERDP_EXPORTS" "#if 1")
    if(WITH_SERVER)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rdtk0/rdtk/api.h" "#ifdef RDTK_EXPORTS" "#if 1")
    endif()
endif()

file(GLOB cmakefiles  "${CURRENT_PACKAGES_DIR}/include/*/CMakeFiles")
file(REMOVE_RECURSE
    ${cmakefiles}
    "${CURRENT_PACKAGES_DIR}/include/winpr3/config"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
