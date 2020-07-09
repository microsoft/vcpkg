set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.kitware.com/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmake/cmake
    REF 615129f3ebd308abeaaee7f5f0689e7fc4616c28
    SHA512 5f02e05b7e6119c9c165c868d0679e0fbe5cc6b4f081a4e63a87d663c029bc378327ec042ae6bfd16bf48737bfaa5bae3be33a6dd33648e1f47cdc1a2370c366
    HEAD_REF master
)
if(EXISTS "${CURRENT_INSTALLED_DIR}/bin/Qt5Core.dll")
    set(QT_IS_STATIC false)
elseif(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libQt5Core.so")
    set(QT_IS_STATIC false)
elseif(EXISTS "${CURRENT_INSTALLED_DIR}/lib/libQt5Core.dylib")
    set(QT_IS_STATIC false)
else()
    set(QT_IS_STATIC true)
endif()
# if(VCPKG_TARGET_IS_WINDOWS AND QT_IS_STATIC)
    # set(qt_prefix "${CURRENT_INSTALLED_DIR}")
    # set(QT_STATIC_RELEASE_LIBS "-DCMake_QT_STATIC_QWindowsIntegrationPlugin_LIBRARIES:STRING=${qt_prefix}/plugins/platforms/qwindows.lib\\\\\\\;${qt_prefix}/plugins/styles/qwindowsvistastyle.lib\\\\\\\;${qt_prefix}/lib/Qt5EventDispatcherSupport.lib\\\\\\\;${qt_prefix}/lib/Qt5FontDatabaseSupport.lib\\\\\\\;${qt_prefix}/lib/Qt5ThemeSupport.lib\\\\\\\;${qt_prefix}/lib/Qt5FontDatabaseSupport.lib\\\\\\\;${qt_prefix}/lib/Qt5AccessibilitySupport.lib\\\\\\\;${qt_prefix}/lib/Qt5WindowsUIAutomationSupport.lib\\\\\\\;${qt_prefix}/lib/Qt5Gui.lib\\\\\\\;${qt_prefix}/lib/Qt5Widgets.lib\\\\\\\;${qt_prefix}/lib/Qt5Core.lib\\\\\\\;${qt_prefix}/lib/freetype.lib\\\\\\\;${qt_prefix}/lib/libpng16.lib\\\\\\\;imm32.lib\\\\\\\;wtsapi32.lib")
    # set(qt_prefix "${CURRENT_INSTALLED_DIR}/debug")
    # set(QT_STATIC_DEBUG_LIBS "-DCMake_QT_STATIC_QWindowsIntegrationPlugin_LIBRARIES:STRING=${qt_prefix}/plugins/platforms/qwindowsd.lib\\\\\\\;${qt_prefix}/plugins/styles/qwindowsvistastyled.lib\\\\\\\;${qt_prefix}/lib/Qt5EventDispatcherSupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5FontDatabaseSupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5ThemeSupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5FontDatabaseSupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5AccessibilitySupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5WindowsUIAutomationSupportd.lib\\\\\\\;${qt_prefix}/lib/Qt5Guid.lib\\\\\\\;${qt_prefix}/lib/Qt5Widgetsd.lib\\\\\\\;${qt_prefix}/lib/Qt5Cored.lib\\\\\\\;${qt_prefix}/lib/freetyped.lib\\\\\\\;${qt_prefix}/lib/libpng16d.lib\\\\\\\;imm32.lib\\\\\\\;wtsapi32.lib")
# endif()

# if(NOT VCPKG_TARGET_IS_WINDOWS AND QT_IS_STATIC)
    # set(qt_prefix "${CURRENT_INSTALLED_DIR}")
    # set(QT_STATIC_RELEASE_LIBS "-DCMake_QT_STATIC_QXcbIntegrationPlugin_LIBRARIES:STRING=${qt_prefix}/plugins/platforms/libqxcb.a\\\\\\\;${qt_prefix}/lib/libQt5XcbQpa.a\\\\\\\;${qt_prefix}/lib/libQt5ServiceSupport.a\\\\\\\;${qt_prefix}/lib/libQt5EdidSupport.a\\\\\\\;${qt_prefix}/lib/libQt5EventDispatcherSupport.a\\\\\\\;${qt_prefix}/lib/libQt5FontDatabaseSupport.a\\\\\\\;${qt_prefix}/lib/libQt5ThemeSupport.a\\\\\\\;${qt_prefix}/lib/libfontconfig.a\\\\\\\;${qt_prefix}/lib/libfreetype.a")
    # set(qt_prefix "${CURRENT_INSTALLED_DIR}/debug")
    # set(QT_STATIC_DEBUG_LIBS "-DCMake_QT_STATIC_QXcbIntegrationPlugin_LIBRARIES:STRING=${qt_prefix}/plugins/platforms/libqxcb.a\\\\\\\;${qt_prefix}/lib/libQt5XcbQpa.a\\\\\\\;${qt_prefix}/lib/libQt5ServiceSupport.a\\\\\\\;${qt_prefix}/lib/libQt5EdidSupport.a\\\\\\\;${qt_prefix}/lib/libQt5EventDispatcherSupport.a\\\\\\\;${qt_prefix}/lib/libQt5FontDatabaseSupport.a\\\\\\\;${qt_prefix}/lib/libQt5ThemeSupport.a\\\\\\\;${qt_prefix}/lib/libfontconfig.a\\\\\\\;${qt_prefix}/lib/libfreetyped.a")
# endif()

#CMake_QT_STATIC_QXcbIntegrationPlugin_LIBRARIES:STRING=${qt_prefix}/plugins/platforms/libqxcb.a;${qt_prefix}/lib/libQt5XcbQpa.a;${qt_prefix}/lib/libQt5ServiceSupport.a;${qt_prefix}/lib/libQt5EdidSupport.a;${qt_prefix}/lib/libQt5EventDispatcherSupport.a;${qt_prefix}/lib/libQt5FontDatabaseSupport.a;${qt_prefix}/lib/libQt5ThemeSupport.a;-lxcb-static;-lxcb;-lfontconfig;-lfreetype

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        #-DCMAKE_USE_SYSTEM_LIBRARIES=ON
        -DCMAKE_USE_SYSTEM_LIBARCHIVE=ON
        -DCMAKE_USE_SYSTEM_CURL=ON
        -DCMAKE_USE_SYSTEM_EXPAT=ON
        -DCMAKE_USE_SYSTEM_ZLIB=ON
        -DCMAKE_USE_SYSTEM_BZIP2=ON
        -DCMAKE_USE_SYSTEM_ZSTD=ON
        -DCMAKE_USE_SYSTEM_FORM=ON
        -DCMAKE_USE_SYSTEM_JSONCPP=ON
        -DCMAKE_USE_SYSTEM_LIBRHASH=OFF # not yet in VCPKG
        -DCMAKE_USE_SYSTEM_LIBUV=ON
        -DBUILD_QtDialog=ON # Just to test Qt with CMake
    # OPTIONS_RELEASE
        # ${QT_STATIC_RELEASE_LIBS}
    # OPTIONS_DEBUG
        # ${QT_STATIC_DEBUG_LIBS}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

set(_tools cmake cmake-gui cmcldeps ctest cpack)
vcpkg_copy_tools(TOOL_NAMES ${_tools} AUTO_CLEAN)
# foreach(_tool IN LISTS _tools)
    # set(_file "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    # if(EXISTS "${_file}")
        # file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        # file(REMOVE "${_file}")
    # endif()
    # set(_file "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    # if(EXISTS "${_file}")
        # file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
        # file(REMOVE "${_file}")
    # endif()
# endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
# vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)