set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
      "clang-cl.patch"
      "adjust-pkg-config.patch"
      "vcpkg-dirs.patch"
      "fix-error2275-2672.patch"
      "add-include-string.patch"

)

set(TOOL_NAMES gn QtWebEngineProcess qwebengine_convert_dict webenginedriver)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "proprietary-codecs"    FEATURE_webengine_proprietary_codecs
    "spellchecker"          FEATURE_webengine_spellchecker
    "geolocation"           FEATURE_webengine_geolocation
    "webchannel"            FEATURE_webengine_webchannel
    "geolocation"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Positioning
    "webchannel"            CMAKE_REQUIRE_FIND_PACKAGE_Qt6WebChannel
INVERTED_FEATURES
    "geolocation"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Positioning
    "webchannel"            CMAKE_DISABLE_FIND_PACKAGE_Qt6WebChannel
)

if(VCPKG_TARGET_IS_OSX AND "spellchecker" IN_LIST FEATRUES)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_native_spellchecker=ON")
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

if(VCPKG_TARGET_IS_LINUX)
    # qt_configure_add_summary_entry(ARGS "webengine-system-lcms2")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libpci")
    # + ALSA and PULSEAUDIO

    set(system_libs re2 icu libwebp opus ffmpeg libvpx snappy glib zlib minizip libxml libpng libjpeg harfbuzz freetype lcms2 libtiff libopenjpeg2) #libevent
    foreach(_sys_lib IN LISTS system_libs)
        list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_system_${_sys_lib}=ON")
    endforeach()
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine_system_libevent=OFF")     # libevent -> issues with getting the include?
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

#vcpkg_find_acquire_program(GN) # Qt builds its own internal version

find_program(NODEJS NAMES node PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/node" PATH_SUFFIXES "bin" NO_DEFAULT_PATH)
#find_program(NODEJS NAMES node)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
  vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/cups/bin")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES html5lib OUT_PYTHON_VAR PYTHON3)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")
set(GPERF "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${VCPKG_HOST_EXECUTABLE_SUFFIX}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
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

##### qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
  find_program(pkgconf NAMES pkgconf pkg-config REQUIRED)
  set(ENV{PKG_CONFIG} "${pkgconf}")
  set(ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
  set(ENV{CFLAGS} "-Wl,-rpath,${CURRENT_INSTALLED_DIR}/lib")
  set(ENV{CXXFLAGS} "-Wl,-rpath,${CURRENT_INSTALLED_DIR}/lib")
endif()

qt_cmake_configure( DISABLE_PARALLEL_CONFIGURE # due to in source changes.
                    OPTIONS ${FEATURE_OPTIONS}
                        -DGPerf_EXECUTABLE=${GPERF}
                        -DBISON_EXECUTABLE=${BISON}
                        -DFLEX_EXECUTABLE=${FLEX}
                        -DNodejs_EXECUTABLE=${NODEJS}
                        -DPython3_EXECUTABLE=${PYTHON3}
                        -DPKG_CONFIG_EXECUTABLE=${pkgconf}
                        -DQT_FEATURE_webengine_jumbo_build=0
                        -DCMAKE_INSTALL_RPATH=${CURRENT_INSTALLED_DIR}/lib
                        -DCMAKE_BUILD_RPATH=${CURRENT_INSTALLED_DIR}/lib
                        #"-DCMAKE_C_FLAGS_RELEASE=-I${CURRENT_INSTALLED_DIR}/include -Wl,-rpath,${CURRENT_INSTALLED_DIR}/lib"
                        #"-DCMAKE_CXX_FLAGS_RELEASE=-I${CURRENT_INSTALLED_DIR}/include -Wl,-rpath,${CURRENT_INSTALLED_DIR}/lib"
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/QtWebEngineProcessd.exe" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/QtWebEngineProcessd.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/QtWebEngineProcessd.pdb" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/debug/QtWebEngineProcessd.pdb")
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/resources" "${CURRENT_PACKAGES_DIR}/share/Qt6/resources") # qt.conf wants it there and otherwise the QtWebEngineProcess cannot start

qt_install_copyright("${SOURCE_PATH}")
