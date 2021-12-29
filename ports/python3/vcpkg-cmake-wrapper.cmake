# For very old ports whose upstream do not properly set the minimum CMake version.
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0057 NEW)

# This prevents the port's python.exe from overriding the Python fetched by
# vcpkg_find_acquire_program(PYTHON3) and prevents the vcpkg toolchain from
# stomping on FindPython's default functionality.
list(REMOVE_ITEM CMAKE_PROGRAM_PATH "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/python3")
if(@PythonFinder_NO_OVERRIDE@)
    _find_package(${ARGS})
    return()
endif()

# CMake's FindPython's separation of concerns is very muddy. We only want to force vcpkg's Python
# if the consumer is using the development component. What we don't want to do is break detection
# of the system Python, which may have certain packages the user expects. But - if the user is
# embedding Python or using both the development and interpreter components, then we need the
# interpreter matching vcpkg's Python libraries. Note that the "Development" component implies
# both "Development.Module" and "Development.Embed"
if("Development" IN_LIST ARGS OR "Development.Embed" IN_LIST ARGS)
    set(_PythonFinder_WantInterp TRUE)
    set(_PythonFinder_WantLibs TRUE)
elseif("Development.Module" IN_LIST ARGS)
    if("Interpreter" IN_LIST ARGS)
        set(_PythonFinder_WantInterp TRUE)
    endif()
    set(_PythonFinder_WantLibs TRUE)
endif()

if(_PythonFinder_WantLibs)
    find_path(
        @PythonFinder_PREFIX@_INCLUDE_DIR
        NAMES "Python.h"
        PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        PATH_SUFFIXES "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
        NO_DEFAULT_PATH
    )

    # Don't set the public facing hint or the finder will be unable to detect the debug library.
    # Internally, it uses the same value with an underscore prepended.
    find_library(
        _@PythonFinder_PREFIX@_LIBRARY_RELEASE
        NAMES
        "python@PYTHON_VERSION_MAJOR@@PYTHON_VERSION_MINOR@"
        "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
        PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
        NO_DEFAULT_PATH
    )
    find_library(
        _@PythonFinder_PREFIX@_LIBRARY_DEBUG
        NAMES
        "python@PYTHON_VERSION_MAJOR@@PYTHON_VERSION_MINOR@_d"
        "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@d"
        PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"
        NO_DEFAULT_PATH
    )

    if(_PythonFinder_WantInterp)
        find_program(
            @PythonFinder_PREFIX@_EXECUTABLE
            NAMES "python" "python@PYTHON_VERSION_MAJOR@.@PYTHON_VERSION_MINOR@"
            PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/python3"
            NO_DEFAULT_PATH
        )
    endif()

    _find_package(${ARGS})

    if(@VCPKG_LIBRARY_LINKAGE@ STREQUAL static)
        include(CMakeFindDependencyMacro)

        # Python for Windows embeds the zlib module into the core, so we have to link against it.
        # This is a separate extension module on Unix-like platforms.
        if(WIN32)
            find_dependency(ZLIB)
            if(TARGET @PythonFinder_PREFIX@::Python)
                set_property(TARGET @PythonFinder_PREFIX@::Python APPEND PROPERTY INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
            endif()
            if(TARGET @PythonFinder_PREFIX@::Module)
                set_property(TARGET @PythonFinder_PREFIX@::Module APPEND PROPERTY INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
            endif()
            if(DEFINED @PythonFinder_PREFIX@_LIBRARIES)
                list(APPEND @PythonFinder_PREFIX@_LIBRARIES ${ZLIB_LIBRARIES})
            endif()
        endif()

        if(APPLE)
            find_dependency(Iconv)
            find_dependency(Intl)
            if(TARGET @PythonFinder_PREFIX@::Python)
                get_target_property(_PYTHON_INTERFACE_LIBS @PythonFinder_PREFIX@::Python INTERFACE_LINK_LIBRARIES)
                list(REMOVE_ITEM _PYTHON_INTERFACE_LIBS "-liconv" "-lintl")
                list(APPEND _PYTHON_INTERFACE_LIBS
                    Iconv::Iconv
                    "$<IF:$<CONFIG:Debug>,${Intl_LIBRARY_DEBUG},${Intl_LIBRARY_RELEASE}>"
                )
                set_property(TARGET @PythonFinder_PREFIX@::Python PROPERTY INTERFACE_LINK_LIBRARIES ${_PYTHON_INTERFACE_LIBS})
                unset(_PYTHON_INTERFACE_LIBS)
            endif()
            if(TARGET @PythonFinder_PREFIX@::Module)
                get_target_property(_PYTHON_INTERFACE_LIBS @PythonFinder_PREFIX@::Module INTERFACE_LINK_LIBRARIES)
                list(REMOVE_ITEM _PYTHON_INTERFACE_LIBS "-liconv" "-lintl")
                list(APPEND _PYTHON_INTERFACE_LIBS
                    Iconv::Iconv
                    "$<IF:$<CONFIG:Debug>,${Intl_LIBRARY_DEBUG},${Intl_LIBRARY_RELEASE}>"
                )
                set_property(TARGET @PythonFinder_PREFIX@::Module PROPERTY INTERFACE_LINK_LIBRARIES ${_PYTHON_INTERFACE_LIBS})
                unset(_PYTHON_INTERFACE_LIBS)
            endif()
            if(DEFINED @PythonFinder_PREFIX@_LIBRARIES)
                list(APPEND @PythonFinder_PREFIX@_LIBRARIES "-framework CoreFoundation" ${Iconv_LIBRARIES} ${Intl_LIBRARIES})
            endif()
        endif()
    endif()
else()
    _find_package(${ARGS})
endif()

unset(_PythonFinder_WantInterp)
unset(_PythonFinder_WantLibs)
