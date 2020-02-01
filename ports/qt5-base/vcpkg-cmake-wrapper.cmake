_find_package(${ARGS})

function(add_qt_library _target)
    foreach(_lib IN LISTS ARGN)
        #The fact that we are within this file means we are using the VCPKG toolchain. Has such we only need to search in VCPKG paths!
        find_library(${_lib}_LIBRARY_DEBUG NAMES ${_lib}_debug ${_lib}d ${_lib} NAMES_PER_DIR PATH_SUFFIXES lib plugins/platforms PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH)
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
    if(WIN32)
    elseif(UNIX AND NOT APPLE)
    elseif(APPLE)
       # set_property(TARGET Qt5::Core APPEND PROPERTY INTERFACE_LINK_LIBRARIES
            # "-weak_framework DiskArbitration" "-weak_framework IOKit" "-weak_framework Foundation" "-weak_framework CoreServices"
            # "-weak_framework AppKit" "-weak_framework Security" "-weak_framework ApplicationServices"
            # "-weak_framework CoreFoundation" "-weak_framework SystemConfiguration"
            # "-weak_framework Carbon"
            # "-weak_framework QuartzCore"
            # "-weak_framework CoreVideo"
            # "-weak_framework Metal"
            # "-weak_framework CoreText"
            # "-weak_framework ApplicationServices"
            # "-weak_framework CoreGraphics"
            # "-weak_framework OpenGL"
            # "-weak_framework AGL"
            # "-weak_framework ImageIO"
            # "z" "m"
            # cups)
    endif()

endif()
