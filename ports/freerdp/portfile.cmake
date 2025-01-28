vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF "${VERSION}"
    SHA512 72d978326a3641e69706c158cd5c4b1a4138dedbe1bf8c0f1c02fbb03291c1a49ff36afdaf8cf432fee84952bbaecf8801efa3f1afb50f600490e36ec3d577ef
    HEAD_REF master
    PATCHES
        dependencies.patch
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
        ffmpeg      WITH_FFMPEG
        ffmpeg      WITH_SWSCALE
        server      WITH_SERVER
        urbdrc      CHANNEL_URBDRC
        wayland     WITH_WAYLAND
        winpr-tools WITH_WINPR_TOOLS
        x11         WITH_X11
)

vcpkg_list(SET GENERATOR_OPTION)
if(VCPKG_TARGET_IS_OSX)
    list(APPEND GENERATOR_OPTION GENERATOR "Unix Makefiles")
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
        -DWITH_AAD=ON
        -DWITH_CCACHE=OFF
        -DWITH_CLANG_FORMAT=OFF
        -DWITH_MANPAGES=OFF
        -DWITH_OPENSSL=ON
        -DWITH_SAMPLE=OFF
        -DWITH_UNICODE_BUILTIN=ON
        -DWITH_CLIENT=OFF
        "-DMSVC_RUNTIME=${VCPKG_CRT_LINKAGE}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
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
        -DVCPKG_TRACE_FIND_PACKAGE=ON
    MAYBE_UNUSED_VARIABLES
        MSVC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_list(SET tools)
if(VCPKG_TARGET_IS_WINDOWS)
    if("server" IN_LIST FEATURES)
        list(APPEND tools wfreerdp-server-cli)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if("server" IN_LIST FEATURES)
        list(APPEND tools mfreerdp-server)
    endif()
endif()
if("server" IN_LIST FEATURES)
    list(APPEND tools freerdp-proxy freerdp-shadow-cli)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Proxy3 PACKAGE_NAME freerdp-Proxy3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Server3 PACKAGE_NAME freerdp-server3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Shadow3 PACKAGE_NAME freerdp-shadow3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rdtk0 PACKAGE_NAME rdtk0 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if("wayland" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uwac0 PACKAGE_NAME uwac0 DO_NOT_DELETE_PARENT_CONFIG_PATH)
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

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp3/freerdp/build-config.h" "\"${CURRENT_PACKAGES_DIR}" "/* vcpkg redacted */ \"" IGNORE_UNCHANGED)
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
