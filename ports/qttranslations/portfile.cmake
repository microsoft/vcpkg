set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  QT_FEATURE_appstore-compliant
    # )

 set(TOOL_NAMES)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
                    
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # only translation files. 

#TODO

# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtbase/src'
  # for qtbase does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:72 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtactiveqt/src'
  # for qtbase does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:72 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtimageformats/src'
  # for qtbase does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:72 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtbase, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:72 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtdeclarative/src'
  # for qtdeclarative does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:78 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtdeclarative, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:78 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtquickcontrols2/src'
  # for qtquickcontrols2 does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:79 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtquickcontrols2, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:79 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtmultimedia/src'
  # for qtmultimedia does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:80 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtmultimedia, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:80 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtconnectivity/src'
  # for qtconnectivity does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:85 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtconnectivity, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:85 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtlocation/src'
  # for qtlocation does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:89 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtlocation, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:89 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtwebsockets/src'
  # for qtwebsockets does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:93 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtwebsockets, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:93 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtserialport/src'
  # for qtserialport does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:94 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtserialport, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:94 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qtwebengine/src'
  # for qtwebengine does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:95 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qtwebengine, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:95 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qttools/src/designer'
  # for designer does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:96 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for designer, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:96 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qttools/src/linguist/linguist'
  # for linguist does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:97 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for linguist, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:97 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qttools/src/assistant/assistant'
  # for assistant does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:98 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for assistant, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:98 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:36 (message):
  # Directory
  # 'E:/vcpkg_folders/qt6/buildtrees/qttranslations/src/.0.0-beta2-f51e1c4cba.clean/translations/../../qttools/src/assistant/help'
  # for qt_help does not exist.  Skipping...
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:99 (add_ts_targets)


# CMake Warning at translations/CMakeLists.txt:43 (message):
  # No source files located for qt_help, skipping target creation
# Call Stack (most recent call first):
  # translations/CMakeLists.txt:99 (add_ts_targets)
