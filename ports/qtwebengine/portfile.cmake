set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
      "clang-cl.patch"
      "cross-build.diff"
      "disable-host-pkgconfig.diff"
      "fix-error2275-2672.patch"
      "nested-name-fix.patch"
      "osx-sdk-info.diff"
      "pdf-system-libjpeg.diff"
      "pdf-system-libpng.diff"
      "pkg-config.diff"
      "rpath.diff"
)

list(REMOVE_ITEM FEATURES "private-dependencies")
set(qtwebengine_target "${VCPKG_TARGET_TRIPLET}-${VCPKG_CMAKE_SYSTEM_NAME}")
if(VCPKG_CROSSCOMPILING)
    if(NOT qtwebengine_host STREQUAL qtwebengine_target)
        # Port limitation: qtwebengine-chromium builds and runs host tools.
        message(WARNING "Building for ${TARGET_TRIPLET} on ${HOST_TRIPLET} is unsupported.")
    endif()
    if(FEATURES STREQUAL "core")
        set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
        return()
    endif()
else()
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" "set(qtwebengine_host \"${qtwebengine_target}\")\n")
    if(FEATURES STREQUAL "core")
        # Install only the custom gn executable.
        set(VCPKG_BUILD_TYPE "release")
        set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
        qt_install_submodule(
            CONFIGURE_OPTIONS
                -DBUILD_ONLY_GN=ON
            CONFIGURE_OPTIONS_MAYBE_UNUSED
                INSTALL_MKSPECSDIR
                QT_BUILD_BENCHMARKS
                QT_BUILD_EXAMPLES
                QT_BUILD_TESTS
                QT_MKSPECS_DIR
                QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
        )
        qt_fixup_and_cleanup(TOOL_NAMES gn)
        qt_install_copyright("${SOURCE_PATH}")
        return()
    endif()
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "geolocation"           FEATURE_webengine_geolocation
    "geolocation"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Positioning
    "pdf"                   FEATURE_qtpdf_build
    "proprietary-codecs"    FEATURE_webengine_proprietary_codecs
    "spellchecker"          FEATURE_webengine_spellchecker
    "webchannel"            FEATURE_webengine_webchannel
    "webchannel"            CMAKE_REQUIRE_FIND_PACKAGE_Qt6WebChannel
    "webengine"             FEATURE_qtwebengine_build
INVERTED_FEATURES
    "geolocation"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Positioning
    "webchannel"            CMAKE_DISABLE_FIND_PACKAGE_Qt6WebChannel
)

if(VCPKG_TARGET_IS_OSX AND "spellchecker" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_native_spellchecker=ON")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" static_runtime)
    list(APPEND FEATURE_OPTIONS "-DQT_FEATURE_static_runtime=${static_runtime}")
endif()

# webengine-extensions
# webengine-printing-and-pdf
# webengine-pepper-plugins
set(deactivated_features   webengine_webrtc_pipewire)
foreach(_feat IN LISTS deactivated_features)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_${_feat}=OFF")
endforeach()
set(enabled_features  webengine_webrtc)
foreach(_feat IN LISTS enabled_features)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_${_feat}=ON")
endforeach()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # qt_configure_add_summary_entry(ARGS "webengine-system-lcms2")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libpci")
    # + ALSA and PULSEAUDIO
    # gbm, libpci ?
    set(system_libs freetype glib harfbuzz libjpeg libpng libtiff libwebp libxml minizip re2 snappy zlib)
    if(NOT VCPKG_TARGET_IS_IOS AND NOT VCPKG_TARGET_IS_OSX)
        list(APPEND system_libs icu)
    endif()
    if("pdfium" IN_LIST FEATURES)
        list(APPEND system_libs lcms2 libopenjpeg2)
    endif()
    if("webengine" IN_LIST FEATURES)
        list(APPEND system_libs ffmpeg opus)
    endif()
    foreach(_sys_lib IN LISTS system_libs)
        list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_system_${_sys_lib}=ON")
    endforeach()
    # vcpkg ports exist, but don't work with chromium
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_system_libevent=OFF")
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_system_libvpx=OFF")

    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    list(APPEND FEATURE_OPTIONS "-DVCPKG_LOCK_FIND_PACKAGE_PkgConfig=ON")
    # Note <installed>/share/Qt6/QtBuildRepoHelpers.cmake
    list(APPEND FEATURE_OPTIONS "-DFEATURE_pkg_config=ON")
    # Note <installed>/share/Qt6BuildInternals/QtBuildInternalsExtra.cmake
    list(APPEND FEATURE_OPTIONS "-DQT_SKIP_BUILD_INTERNALS_PKG_CONFIG_FEATURE=ON")
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

#vcpkg_find_acquire_program(GN) # Qt builds its own internal version

find_program(NODEJS
    NAMES node
    PATHS
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node"
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin"
        ENV PATH
    NO_DEFAULT_PATH
)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

function(download_distfile var url sha512)
    string(REGEX REPLACE ".*/" "" filename "${url}")
    vcpkg_download_distfile(archive
        URLS "${url}"
        FILENAME "${filename}"
        SHA512 "${sha512}"
    )
    set("${var}" "${archive}" PARENT_SCOPE)
endfunction()

download_distfile(html5lib
    "https://files.pythonhosted.org/packages/6c/dd/a834df6482147d48e225a49515aabc28974ad5a4ca3215c18a882565b028/html5lib-1.1-py2.py3-none-any.whl"
    53e828155e489176e8ea0cdc941ec6271764bbf7069b1a83c0ce8adb26694450d17d7c76b4a00a14dbb99ca203ae02b3d8c8e41953fd59499bbc8a8d4900975b
)
download_distfile(six
    "https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl"
    2796b93aaac73193faeb5c93a85d23c2ae9fc4a7e57df88dc34b704a36fa62cd0b1fb5d1a74b961a23eff2467be94eb14f5f10874dfa733dc4ab59715280bbf3
)
download_distfile(webencodings
    "https://files.pythonhosted.org/packages/f4/24/2a3e3df732393fed8b3ebf2ec078f05546de641fe1b667ee316ec1dcf3b7/webencodings-0.5.1-py2.py3-none-any.whl"
    2a34dbebc33a44a3691216104982b4a978a2a60b38881fc3704d04cb1da38ea2878b5ffec5ac19ac43f50d00c8d4165e05fdf6fa4363a564d8c5090411fc392d
)
x_vcpkg_get_python_packages(
    OUT_PYTHON_VAR PYTHON3
    PYTHON_VERSION 3
    PACKAGES --no-index "${html5lib}" "${six}" "${webencodings}"
)
get_filename_component(PYTHON_DIR "${PYTHON3}" DIRECTORY )
vcpkg_add_to_path(APPEND "${PYTHON_DIR}")

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")
set(GPERF "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${VCPKG_HOST_EXECUTABLE_SUFFIX}")

if(CMAKE_HOST_WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtree_length)
# We know that C:/buildrees/${PORT} is to long to build Release. Debug works however. Means 24 length is too much but 23 might work.
if(buildtree_length GREATER 22 AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    message(WARNING "Buildtree path '${CURRENT_BUILDTREES_DIR}' is too long.\nConsider passing --x-buildtrees-root=<shortpath> to vcpkg!\nTrying to use '${CURRENT_BUILDTREES_DIR}/../tmp'")
    set(CURRENT_BUILDTREES_DIR "${CURRENT_BUILDTREES_DIR}/../tmp") # activly avoid long path issues in CI. -> Means CI will not return logs
    cmake_path(NORMAL_PATH CURRENT_BUILDTREES_DIR)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtree_length_new)
    if(buildtree_length_new GREATER 22)
         message(FATAL_ERROR "Buildtree path is too long. Build will fail! Pass --x-buildtrees-root=<shortpath> to vcpkg!")
    endif()
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}")
endif()

set(ENV{QTWEBENGINE_GN_THREADS} "${VCPKG_CONCURRENCY}")
set(ENV{NINJAFLAGS} "-j${VCPKG_CONCURRENCY} $ENV{NINJAFLAGS}")

##### qt_install_submodule, unrolled
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

qt_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE # due to in source changes.
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DGPerf_EXECUTABLE=${GPERF}"
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DNodejs_EXECUTABLE=${NODEJS}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -DQT_FEATURE_webengine_jumbo_build=0
        -DVCPKG_LOCK_FIND_PACKAGE_BISON=ON
        -DVCPKG_LOCK_FIND_PACKAGE_FLEX=ON
        -DVCPKG_LOCK_FIND_PACKAGE_GPerf=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Ninja=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Nodejs=ON
    OPTIONS_MAYBE_UNUSED
        FEATURE_webengine_webrtc
)

vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
file(GLOB target_args_gn RELATIVE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/core/Release" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/core/Release/*/args.gn")
if(NOT VCPKG_BUILD_TYPE)
    block(SCOPE_FOR VARIABLES)
    set(VCPKG_BUILD_TYPE debug)
    if(VCPKG_TARGET_IS_LINUX AND EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/core/Debug/${target_args_gn}")
        file(APPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/core/Debug/${target_args_gn}" "\ngcc_target_rpath=\"\\\${ORIGIN}:${CURRENT_INSTALLED_DIR}/debug/lib\"\n")
    endif()
    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig" "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
    vcpkg_cmake_install(ADD_BIN_TO_PATH)
    endblock()
endif()
vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)
block(SCOPE_FOR VARIABLES)
set(VCPKG_BUILD_TYPE release)
if(VCPKG_TARGET_IS_LINUX AND EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/core/Release/${target_args_gn}")
    file(APPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/core/Release/${target_args_gn}" "\ngcc_target_rpath=\"\\\${ORIGIN}:${CURRENT_INSTALLED_DIR}/lib\"\n")
endif()
vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig" "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
vcpkg_cmake_install(ADD_BIN_TO_PATH)
endblock()
vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)

# Unroll response file references.
# Escape quotes in a way which survives vcpkg_cmake_config_fixup().
file(GLOB cmake_target_files "${CURRENT_PACKAGES_DIR}/share/Qt6*/Qt6*Targets.cmake" "${CURRENT_PACKAGES_DIR}/debug/share/Qt6*/Qt6*Targets.cmake")
foreach(file IN LISTS cmake_target_files)
    file(READ "${file}" haystack)
    while(haystack MATCHES "@([^>]*[.]rsp)")
        set(response_file "${CMAKE_MATCH_1}")
        if(EXISTS "${response_file}")
            file(STRINGS "${response_file}" options)
            string(REPLACE [["]] [[${_escaped_quote_}]] options "${options}")
            list(JOIN options " " replacement)
        else()
            message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "No such response file: ${response_file}")
            set(replacement "")
        endif()
        string(REPLACE "@${response_file}" "${replacement}" haystack "${haystack}")
    endwhile()
    file(WRITE "${file}" [[set(_escaped_quote_ "\"")]] "\n\n${haystack}")
endforeach()

qt_fixup_and_cleanup(TOOL_NAMES gn QtWebEngineProcess qwebengine_convert_dict webenginedriver)
if("webengine" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/QtWebEngineProcessd.exe" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/QtWebEngineProcessd.exe")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/QtWebEngineProcessd.pdb" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/QtWebEngineProcessd.pdb")
    endif()
    file(RENAME "${CURRENT_PACKAGES_DIR}/resources" "${CURRENT_PACKAGES_DIR}/share/Qt6/resources") # qt.conf wants it there and otherwise the QtWebEngineProcess cannot start
endif()

qt_install_copyright("${SOURCE_PATH}")

##### qt_install_submodule
