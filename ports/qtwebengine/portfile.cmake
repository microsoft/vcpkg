set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(TOOL_NAMES gn QtWebEngineProcess qwebengine_convert_dict)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "proprietary-codecs"    FEATURE_webengine-proprietary-codecs
    "spellchecker"          FEATURE_webengine-spellchecker
    "geolocation"           FEATURE_webengine-geolocation
    "webchannel"            FEATURE_webengine-webchannel
INVERTED_FEATURES
    "geolocation"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Positioning
    "webchannel"            CMAKE_DISABLE_FIND_PACKAGE_Qt6WebChannel
)

if(VCPKG_TARGET_IS_OSX AND "spellchecker" IN_LIST FEATRUES)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine-native-spellchecker=ON")
endif()

# webengine-extensions
# webengine-printing-and-pdf
# webengine-pepper-plugins
set(deactivated_features  webengine-webrtc webengine-webrtc-pipewire webengine-v8-snapshot-support)
foreach(_feat IN LISTS deactivated_features)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_${_feat}=OFF")
endforeach()

if(VCPKG_TARGET_IS_LINUX)
    # qt_configure_add_summary_entry(ARGS "webengine-system-lcms2")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libpci")
    # + ALSA and PULSEAUDIO
    set(system_libs re2 icu libwebp opus ffmpeg libvpx snappy glib zlib minizip libevent protobuf libxml libpng libjpeg harfbuzz freetype)
    foreach(_sys_lib IN LISTS system_libs)
        list(APPEND FEATURE_OPTIONS "-DFEATURE_webengine-system-${_sys_lib}=ON")
    endforeach()
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(PYTHON2)

#vcpkg_find_acquire_program(GN) # Qt builds its own internal version

find_program(NODEJS NAMES node PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/node"  "bin" NO_DEFAULT_PATHS)
find_program(NODEJS NAMES node)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${GPERF_DIR}")
get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

### Download third_party modules
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_WEBENGINE
    URL git://code.qt.io/qt/qtwebengine-chromium.git
    REF 202e34476e934633b3c2e4679a53c4b0847364a8
)

##### qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()
if(NOT EXISTS "${SOURCE_PATH}/src/3rdparty/chromium")
    file(RENAME "${SOURCE_PATH_WEBENGINE}/chromium" "${SOURCE_PATH}/src/3rdparty/chromium")
endif()
if(NOT EXISTS "${SOURCE_PATH}/src/3rdparty/gn")
    file(RENAME "${SOURCE_PATH_WEBENGINE}/gn" "${SOURCE_PATH}/src/3rdparty/gn")
endif()

qt_cmake_configure(OPTIONS ${FEATURE_OPTIONS}
                        -DGPerf_EXECUTABLE=${GPERF}
                        -DBISON_EXECUTABLE=${BISON}
                        -DFLEX_EXECUTABLE=${FLEX}
                        #-DGn_EXECUTABLE=${GN}
                        -DPython2_EXECUTABLE=${PYTHON2}
                        -DNodejs_EXECUTABLE=${NODEJS}
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_install_cmake(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

##### qt_install_submodule
