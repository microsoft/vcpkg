_find_package(${ARGS})

function(add_qt_library _target)
    foreach(_lib IN LISTS ARGN)
        #The fact that we are within this file means we are using the VCPKG toolchain. Has such we only need to search in VCPKG paths!
        find_library(${_lib}_LIBRARY_DEBUG NAMES ${_lib}d ${_lib} NAMES_PER_DIR PATH_SUFFIXES lib plugins/platforms PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH)
        find_library(${_lib}_LIBRARY_RELEASE NAMES ${_lib} NAMES_PER_DIR PATH_SUFFIXES lib plugins/platforms PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH)
        if(${_lib}_LIBRARY_RELEASE)
            list(APPEND interface_lib \$<\$<NOT:\$<CONFIG:DEBUG>>:${${_lib}_LIBRARY_RELEASE}>)
        endif()
        if(${_lib}_LIBRARY_DEBUG)
            list(APPEND interface_lib \$<\$<CONFIG:DEBUG>:${${_lib}_LIBRARY_DEBUG}>)
        endif()
        set_property(TARGET ${_target} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${interface_lib})
    endforeach()
endfunction()

get_target_property(_target_type Qt5::Core TYPE)
if("${_target_type}" STREQUAL "STATIC_LIBRARY")
    find_package(ZLIB)
    find_package(JPEG)
    find_package(PNG)
    find_package(Freetype)
    find_package(sqlite3 CONFIG)
    find_package(PostgreSQL MODULE REQUIRED)
    find_package(double-conversion CONFIG)
    find_package(OpenSSL)
    find_package(harfbuzz CONFIG)

    set_property(TARGET Qt5::Core APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        ZLIB::ZLIB JPEG::JPEG PNG::PNG Freetype::Freetype sqlite3 harfbuzz::harfbuzz
        double-conversion::double-conversion OpenSSL::SSL OpenSSL::Crypto PostgreSQL::PostgreSQL
    )
    if(NOT WINDOWS_STORE)
        set_property(TARGET Qt5::Core APPEND PROPERTY INTERFACE_LINK_LIBRARIES
           UxTheme.lib) # Should probably be added to Qt5:Gui and not core but currently we only have that one wrapper
    endif()

    add_qt_library(Qt5::Core
        pcre2-16
        icuin icui18n
        icutu icuuc icuio
        icudt icudata
        Qt5ThemeSupport
        Qt5EventDispatcherSupport
        Qt5PlatformCompositorSupport
        Qt5FontDatabaseSupport)

    if(MSVC)
       set_property(TARGET Qt5::Core APPEND PROPERTY INTERFACE_LINK_LIBRARIES
           Netapi32.lib Ws2_32.lib Mincore.lib Winmm.lib Iphlpapi.lib Wtsapi32.lib Dwmapi.lib Imm32.lib)

      add_qt_library(Qt5::Core Qt5WindowsUIAutomationSupport qwindows qdirect2d)
    elseif(UNIX AND NOT APPLE)
      add_qt_library(Qt5::Core
            Qt5GraphicsSupport
            Qt5ClipboardSupport
            Qt5AccessibilitySupport)
    elseif(APPLE)
       set_property(TARGET Qt5::Core APPEND PROPERTY INTERFACE_LINK_LIBRARIES
            "-weak_framework DiskArbitration" "-weak_framework IOKit" "-weak_framework Foundation" "-weak_framework CoreServices"
            "-weak_framework AppKit" "-weak_framework Security" "-weak_framework ApplicationServices"
            "-weak_framework CoreFoundation" "-weak_framework SystemConfiguration"
            "-weak_framework Carbon"
            "-weak_framework QuartzCore"
            "-weak_framework CoreVideo"
            "-weak_framework Metal"
            "-weak_framework CoreText"
            "-weak_framework ApplicationServices"
            "-weak_framework CoreGraphics"
            "-weak_framework OpenGL"
            "-weak_framework AGL"
            "-weak_framework ImageIO"
            "z" "m"
            cups)
        add_qt_library(Qt5::Core
            Qt5GraphicsSupport
            Qt5ClipboardSupport
            Qt5AccessibilitySupport
            qcocoa)
    endif()

endif()
