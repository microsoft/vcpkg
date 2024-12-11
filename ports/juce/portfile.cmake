vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO juce-framework/JUCE
  REF "${VERSION}"
  SHA512 c1cb2f315c2b3b9c534d21b16d31e641661fbb9ad55b29a0949c038cb69cce65d35c8c669a400e33fdcedd7fc5ef578a1eba787826d525402330551c4d240fe6
  HEAD_REF master
  PATCHES
    0001-build-allow-setting-JUCE_PLUGINHOST_LADSPA.patch
    0002-build-linux-find_packages.patch
    0004-install-paths.patch
    gcc-has-builtin.diff
    header-install-path.diff
    install-extras.diff
    juceaide.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
  "extras"      JUCE_BUILD_EXTRAS
  "ladspa"      JUCE_PLUGINHOST_LADSPA
  "jack"        JUCE_JACK
  "curl"        JUCE_USE_CURL
  "freetype"    JUCE_USE_FREETYPE
  "xcursor"     JUCE_USE_XCURSOR
  "xinerama"    JUCE_USE_XINERAMA
  "xrandr"      JUCE_USE_XRANDR
  "xrender"     JUCE_USE_XRENDER
  "web-browser" JUCE_WEB_BROWSER
  "opengl"      JUCE_OPENGL
)
# Based on https://github.com/juce-framework/JUCE/blob/master/docs/Linux%20Dependencies.md
if(VCPKG_TARGET_IS_LINUX)
  message("juce currently requires the following programs from the system package manager:
  libx11-dev libxcomposite-dev libxext-dev
On Ubuntu derivatives:
    sudo apt install libx11-dev libxcomposite-dev libxext-dev
")
  if(JUCE_OPENGL)
    message("juce with opengl feature requires the following packages via the system package manager:
  libglu1-mesa-dev mesa-common-dev
On Ubuntu derivatives:
  sudo apt install libglu1-mesa-dev mesa-common-dev
")
  endif()

  if(${JUCE_PLUGINHOST_LADSPA})
    message("juce with ladspa feature requires the following packages via the system package manager:
  ladspa-sdk
On Ubuntu derivatives:
  sudo apt install ladspa-sdk
")
  endif()

  if(JUCE_USE_XCURSOR)
    message("juce with xcursor feature requires the following packages via the system package manager:
  libxcursor-dev
On Ubuntu derivatives:
  sudo apt install libxcursor-dev
")
  endif()

  if(JUCE_USE_XINERAMA)
    message("juce with xinerama feature requires the following packages via the system package manager:
  libxinerama-dev
On Ubuntu derivatives:
  sudo apt install libxinerama-dev
")
  endif()

  if(JUCE_USE_XRANDR)
    message("juce with xrandr feature requires the following packages via the system package manager:
  libxrandr-dev
On Ubuntu derivatives:
  sudo apt install libxrandr-dev
")
  endif()

  if(JUCE_USE_XRENDER)
    message("juce with xrender feature requires the following packages via the system package manager:
  libxrender-dev
On Ubuntu derivatives:
  sudo apt install libxrender-dev
")
  endif()

  if(JUCE_WEB_BROWSER)
    message("juce with web-browser feature requires the following packages via the system package manager:
  libwebkit2gtk-4.0-dev
On Ubuntu derivatives:
  sudo apt install libwebkit2gtk-4.0-dev
")
  endif()
endif()

if(VCPKG_CROSSCOMPILING)
  # Constructed with CURRENT_INSTALLED_DIR, for vcpkg_cmake_config_fixup.
  list(APPEND FEATURE_OPTIONS "-DWITH_JUCEAIDE=${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/${PORT}/juceaide${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DJUCE_ENABLE_MODULE_SOURCE_GROUPS=ON
    -DJUCE_INSTALL_DESTINATION=share/juce
    -DJUCE_TOOL_INSTALL_DIR=bin
    ${FEATURE_OPTIONS}
  MAYBE_UNUSED_VARIABLES
    JUCE_TOOL_INSTALL_DIR
    JUCE_PLUGINHOST_LADSPA
    JUCE_JACK
    JUCE_OPENGL
    JUCE_USE_CURL
    JUCE_USE_FREETYPE
    JUCE_USE_XCURSOR
    JUCE_USE_XINERAMA
    JUCE_USE_XRANDR
    JUCE_USE_XRENDER
    JUCE_WEB_BROWSER
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

set(tool_names "")
file(GLOB tools "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(tool IN LISTS tools)
  get_filename_component(name "${tool}" NAME_WE)
  list(APPEND tool_names "${name}")
endforeach()
if(tool_names)
  vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

# Remove duplicate debug files
file(REMOVE_RECURSE
"${CURRENT_PACKAGES_DIR}/debug/"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
