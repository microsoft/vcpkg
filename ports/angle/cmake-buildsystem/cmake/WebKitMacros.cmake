# This file is for macros that are used by multiple projects. If your macro is
# exclusively needed in only one subdirectory of Source (e.g. only needed by
# WebCore), then put it there instead.

macro(WEBKIT_COMPUTE_SOURCES _framework)
    set(_derivedSourcesPath ${${_framework}_DERIVED_SOURCES_DIR})

    foreach (_sourcesListFile IN LISTS ${_framework}_UNIFIED_SOURCE_LIST_FILES)
      configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${_sourcesListFile}" "${_derivedSourcesPath}/${_sourcesListFile}" COPYONLY)
      message(STATUS "Using source list file: ${_sourcesListFile}")

      list(APPEND _sourceListFileTruePaths "${CMAKE_CURRENT_SOURCE_DIR}/${_sourcesListFile}")
    endforeach ()

    if (ENABLE_UNIFIED_BUILDS)
        execute_process(COMMAND ${RUBY_EXECUTABLE} ${WTF_SCRIPTS_DIR}/generate-unified-source-bundles.rb
            "--derived-sources-path" "${_derivedSourcesPath}"
            "--source-tree-path" ${CMAKE_CURRENT_SOURCE_DIR}
            "--print-bundled-sources"
            ${_sourceListFileTruePaths}
            RESULT_VARIABLE _resultTmp
            OUTPUT_VARIABLE _outputTmp)

        if (${_resultTmp})
             message(FATAL_ERROR "generate-unified-source-bundles.rb exited with non-zero status, exiting")
        endif ()

        foreach (_sourceFileTmp IN LISTS _outputTmp)
            set_source_files_properties(${_sourceFileTmp} PROPERTIES HEADER_FILE_ONLY ON)
            list(APPEND ${_framework}_HEADERS ${_sourceFileTmp})
        endforeach ()
        unset(_sourceFileTmp)

        execute_process(COMMAND ${RUBY_EXECUTABLE} ${WTF_SCRIPTS_DIR}/generate-unified-source-bundles.rb
            "--derived-sources-path" "${_derivedSourcesPath}"
            "--source-tree-path" ${CMAKE_CURRENT_SOURCE_DIR}
            ${_sourceListFileTruePaths}
            RESULT_VARIABLE  _resultTmp
            OUTPUT_VARIABLE _outputTmp)

        if (${_resultTmp})
            message(FATAL_ERROR "generate-unified-source-bundles.rb exited with non-zero status, exiting")
        endif ()

        list(APPEND ${_framework}_SOURCES ${_outputTmp})
        unset(_resultTmp)
        unset(_outputTmp)
    else ()
        execute_process(COMMAND ${RUBY_EXECUTABLE} ${WTF_SCRIPTS_DIR}/generate-unified-source-bundles.rb
            "--derived-sources-path" "${_derivedSourcesPath}"
            "--source-tree-path" ${CMAKE_CURRENT_SOURCE_DIR}
            "--print-all-sources"
            ${_sourceListFileTruePaths}
            RESULT_VARIABLE _resultTmp
            OUTPUT_VARIABLE _outputTmp)

        if (${_resultTmp})
             message(FATAL_ERROR "generate-unified-source-bundles.rb exited with non-zero status, exiting")
        endif ()

        list(APPEND ${_framework}_SOURCES ${_outputTmp})
        unset(_resultTmp)
        unset(_outputTmp)
    endif ()
endmacro()

macro(WEBKIT_INCLUDE_CONFIG_FILES_IF_EXISTS)
    set(_file ${CMAKE_CURRENT_SOURCE_DIR}/Platform${PORT}.cmake)
    if (EXISTS ${_file})
        message(STATUS "Using platform-specific CMakeLists: ${_file}")
        include(${_file})
    else ()
        message(STATUS "Platform-specific CMakeLists not found: ${_file}")
    endif ()
endmacro()

# Append the given dependencies to the source file
macro(WEBKIT_ADD_SOURCE_DEPENDENCIES _source _deps)
    set(_tmp)
    get_source_file_property(_tmp ${_source} OBJECT_DEPENDS)
    if (NOT _tmp)
        set(_tmp "")
    endif ()

    foreach (f ${_deps})
        list(APPEND _tmp "${f}")
    endforeach ()

    set_source_files_properties(${_source} PROPERTIES OBJECT_DEPENDS "${_tmp}")
    unset(_tmp)
endmacro()

macro(WEBKIT_ADD_PRECOMPILED_HEADER _header _cpp _source)
    if (MSVC)
        get_filename_component(PrecompiledBasename ${_cpp} NAME_WE)
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${_source}")
        set(PrecompiledBinary "${CMAKE_CURRENT_BINARY_DIR}/${_source}/${PrecompiledBasename}.pch")
        set(_sources ${${_source}})

        # clang-cl requires /FI with /Yc
        if (COMPILER_IS_CLANG_CL)
            set_source_files_properties(${_cpp}
                PROPERTIES COMPILE_FLAGS "/Yc\"${_header}\" /Fp\"${PrecompiledBinary}\" /FI\"${_header}\""
                OBJECT_OUTPUTS "${PrecompiledBinary}")
        else ()
            set_source_files_properties(${_cpp}
                PROPERTIES COMPILE_FLAGS "/Yc\"${_header}\" /Fp\"${PrecompiledBinary}\""
                OBJECT_OUTPUTS "${PrecompiledBinary}")
        endif ()
        set_source_files_properties(${_sources}
            PROPERTIES COMPILE_FLAGS "/Yu\"${_header}\" /FI\"${_header}\" /Fp\"${PrecompiledBinary}\"")

        foreach (_src ${_sources})
            WEBKIT_ADD_SOURCE_DEPENDENCIES(${_src} ${PrecompiledBinary})
        endforeach ()

        list(APPEND ${_source} ${_cpp})
    endif ()
    #FIXME: Add support for Xcode.
endmacro()

macro(WEBKIT_FRAMEWORK_DECLARE _target)
    # add_library() without any source files triggers CMake warning
    # Addition of dummy "source" file does not result in any changes in generated build.ninja file
    add_library(${_target} ${${_target}_LIBRARY_TYPE} "${CMAKE_BINARY_DIR}/cmakeconfig.h")
endmacro()

macro(WEBKIT_EXECUTABLE_DECLARE _target)
    add_executable(${_target} "${CMAKE_BINARY_DIR}/cmakeconfig.h")
endmacro()

# Private macro for setting the properties of a target.
# Rather than just having _target like WEBKIT_FRAMEWORK and WEBKIT_EXECUTABLE the parameters are
# split into _target_logical_name, which is used for variable expansion, and _target_cmake_name.
# This is done to support WEBKIT_WRAP_EXECUTABLE which uses the _target_logical_name variables
# but requires a different _target_cmake_name.
macro(_WEBKIT_TARGET _target_logical_name _target_cmake_name)
    target_sources(${_target_cmake_name} PRIVATE
        ${${_target_logical_name}_HEADERS}
        ${${_target_logical_name}_SOURCES}
    )

    if (PLAYSTATION AND CMAKE_GENERATOR MATCHES "Visual Studio")
        set(${_target_logical_name}_SOURCES_C ${${_target_logical_name}_SOURCES})
        list(FILTER ${_target_logical_name}_SOURCES_C INCLUDE REGEX "\\.c$")
        set_source_files_properties(
            ${${_target_logical_name}_SOURCES_C}
            PROPERTIES LANGUAGE C
            COMPILE_OPTIONS --std=gnu17
        )
    endif ()

    target_include_directories(${_target_cmake_name} PUBLIC "$<BUILD_INTERFACE:${${_target_logical_name}_INCLUDE_DIRECTORIES}>")
    target_include_directories(${_target_cmake_name} SYSTEM PRIVATE "$<BUILD_INTERFACE:${${_target_logical_name}_SYSTEM_INCLUDE_DIRECTORIES}>")
    target_include_directories(${_target_cmake_name} PRIVATE "$<BUILD_INTERFACE:${${_target_logical_name}_PRIVATE_INCLUDE_DIRECTORIES}>")

    if (DEVELOPER_MODE_CXX_FLAGS)
        target_compile_options(${_target_cmake_name} PRIVATE ${DEVELOPER_MODE_CXX_FLAGS})
    endif ()

    target_compile_definitions(${_target_cmake_name} PRIVATE "BUILDING_${_target_logical_name}")
    if (${_target_logical_name}_DEFINITIONS)
        target_compile_definitions(${_target_cmake_name} PUBLIC ${${_target_logical_name}_DEFINITIONS})
    endif ()
    if (${_target_logical_name}_PRIVATE_DEFINITIONS)
        target_compile_definitions(${_target_cmake_name} PRIVATE ${${_target_logical_name}_PRIVATE_DEFINITIONS})
    endif ()

    if (${_target_logical_name}_LIBRARIES)
        target_link_libraries(${_target_cmake_name} PUBLIC ${${_target_logical_name}_LIBRARIES})
    endif ()
    if (${_target_logical_name}_PRIVATE_LIBRARIES)
        target_link_libraries(${_target_cmake_name} PRIVATE ${${_target_logical_name}_PRIVATE_LIBRARIES})
    endif ()

    if (${_target_logical_name}_DEPENDENCIES)
        add_dependencies(${_target_cmake_name} ${${_target_logical_name}_DEPENDENCIES})
    endif ()
endmacro()

macro(_WEBKIT_TARGET_ANALYZE _target)
    if (ClangTidy_EXE)
        set(_clang_path_and_options
            ${ClangTidy_EXE}
            # Include all non system headers
            --header-filter=.*
        )
        set_target_properties(${_target} PROPERTIES
            C_CLANG_TIDY "${_clang_path_and_options}"
            CXX_CLANG_TIDY "${_clang_path_and_options}"
        )
    endif ()

    if (IWYU_EXE)
        set(_iwyu_path_and_options
            ${IWYU_EXE}
            # Suggests the more concise syntax introduced in C++17
            -Xiwyu --cxx17ns
            # Tells iwyu to always keep these includes
            -Xiwyu --keep=**/config.h
        )
        if (MSVC)
            list(APPEND _iwyu_path_and_options --driver-mode=cl)
        endif ()
        set_target_properties(${_target} PROPERTIES
            CXX_INCLUDE_WHAT_YOU_USE "${_iwyu_path_and_options}"
        )
    endif ()
endmacro()

function(_WEBKIT_LINK_FRAMEWORK_INTO target_name framework _public_frameworks_var _private_frameworks_var)
    set_property(GLOBAL PROPERTY ${framework}_LINKED_INTO ${target_name})

    get_property(_framework_public_frameworks GLOBAL PROPERTY ${framework}_FRAMEWORKS)
    foreach (dependency IN LISTS ${_framework_public_frameworks})
        set(${_public_frameworks_var} "${${_public_frameworks_var}};${dependency}" PARENT_SCOPE)
    endforeach ()

    get_property(_framework_private_frameworks GLOBAL PROPERTY ${framework}_PRIVATE_FRAMEWORKS)
    foreach (dependency IN LISTS _framework_private_frameworks)
        set(${_private_frameworks_var} "${${_private_frameworks_var}};${dependency}" PARENT_SCOPE)
        _WEBKIT_LINK_FRAMEWORK_INTO(${target_name} ${dependency} ${_public_frameworks_var} ${_private_frameworks_var})
    endforeach ()
endfunction()

macro(_WEBKIT_FRAMEWORK_LINK_FRAMEWORK _target_name)
    # Set the public libraries before modifying them when determining visibility.
    set_property(GLOBAL PROPERTY ${_target_name}_PUBLIC_LIBRARIES ${${_target_name}_LIBRARIES})

    set(_public_frameworks)
    set(_private_frameworks)

    foreach (framework IN LISTS ${_target_name}_FRAMEWORKS)
        get_property(_linked_into GLOBAL PROPERTY ${framework}_LINKED_INTO)
        if (_linked_into)
            list(APPEND _public_frameworks ${_linked_into})
        elseif (${framework}_LIBRARY_TYPE STREQUAL "SHARED")
            list(APPEND _public_frameworks ${framework})
        else ()
            list(APPEND _private_frameworks ${framework})
        endif ()
    endforeach ()

    # Recurse into the dependent frameworks
    if (_private_frameworks)
        list(REMOVE_DUPLICATES _private_frameworks)
    endif ()
    if (${_target_name}_LIBRARY_TYPE STREQUAL "SHARED")
        set_property(GLOBAL PROPERTY ${_target_name}_LINKED_INTO ${_target_name})
        foreach (framework IN LISTS _private_frameworks)
            _WEBKIT_LINK_FRAMEWORK_INTO(${_target_name} ${framework} _public_frameworks _private_frameworks)
        endforeach ()
    endif ()

    # Add to the ${target_name}_LIBRARIES
    if (_public_frameworks)
        list(REMOVE_DUPLICATES _public_frameworks)
    endif ()
    foreach (framework IN LISTS _public_frameworks)
        # FIXME: https://bugs.webkit.org/show_bug.cgi?id=231774
        if (APPLE)
            list(APPEND ${_target_name}_PRIVATE_LIBRARIES WebKit::${framework})
        else ()
            list(APPEND ${_target_name}_LIBRARIES WebKit::${framework})
        endif ()
    endforeach ()

    # Add to the ${target_name}_PRIVATE_LIBRARIES
    if (_private_frameworks)
        list(REMOVE_DUPLICATES _private_frameworks)
    endif ()
    foreach (framework IN LISTS _private_frameworks)
        if (${_target_name}_LIBRARY_TYPE STREQUAL "SHARED")
            get_property(_linked_libraries GLOBAL PROPERTY ${framework}_PUBLIC_LIBRARIES)
            list(APPEND ${_target_name}_INTERFACE_LIBRARIES
                ${_linked_libraries}
            )
            list(APPEND ${_target_name}_INTERFACE_INCLUDE_DIRECTORIES
                ${${framework}_FRAMEWORK_HEADERS_DIR}
                ${${framework}_PRIVATE_FRAMEWORK_HEADERS_DIR}
            )
            list(APPEND ${_target_name}_PRIVATE_LIBRARIES WebKit::${framework})
            if (${framework}_LIBRARY_TYPE STREQUAL "OBJECT")
                list(APPEND ${_target_name}_PRIVATE_LIBRARIES $<TARGET_OBJECTS:${framework}>)
            endif ()
        else ()
            list(APPEND ${_target_name}_LIBRARIES WebKit::${framework})
        endif ()
    endforeach ()

    set_property(GLOBAL PROPERTY ${_target_name}_FRAMEWORKS ${_public_frameworks})
    set_property(GLOBAL PROPERTY ${_target_name}_PRIVATE_FRAMEWORKS ${_private_frameworks})
endmacro()

macro(_WEBKIT_EXECUTABLE_LINK_FRAMEWORK _target)
    foreach (framework IN LISTS ${_target}_FRAMEWORKS)
        get_property(_linked_into GLOBAL PROPERTY ${framework}_LINKED_INTO)

        # See if the executable is linking a framework that the specified framework is already linked into
        if ((NOT _linked_into) OR (${framework} STREQUAL ${_linked_into}) OR (NOT ${_linked_into} IN_LIST ${_target}_FRAMEWORKS))
            list(APPEND ${_target}_PRIVATE_LIBRARIES WebKit::${framework})

            # The WebKit:: alias targets do not propagate OBJECT libraries so the
            # underyling library's objects are explicitly added to link properly
            if (TARGET ${framework} AND ${framework}_LIBRARY_TYPE STREQUAL "OBJECT")
                list(APPEND ${_target}_PRIVATE_LIBRARIES $<TARGET_OBJECTS:${framework}>)
            endif ()
        endif ()
    endforeach ()
endmacro()

macro(WEBKIT_FRAMEWORK _target)
    _WEBKIT_FRAMEWORK_LINK_FRAMEWORK(${_target})
    _WEBKIT_TARGET(${_target} ${_target})
    _WEBKIT_TARGET_ANALYZE(${_target})

    if (${_target}_OUTPUT_NAME)
        set_target_properties(${_target} PROPERTIES OUTPUT_NAME ${${_target}_OUTPUT_NAME})
    endif ()

    if (${_target}_PRE_BUILD_COMMAND)
        add_custom_target(_${_target}_PreBuild COMMAND ${${_target}_PRE_BUILD_COMMAND} VERBATIM)
        add_dependencies(${_target} _${_target}_PreBuild)
    endif ()

    if (${_target}_POST_BUILD_COMMAND)
        add_custom_command(TARGET ${_target} POST_BUILD COMMAND ${${_target}_POST_BUILD_COMMAND} VERBATIM)
    endif ()

    if (APPLE AND NOT PORT STREQUAL "GTK" AND NOT ${${_target}_LIBRARY_TYPE} MATCHES STATIC)
        set_target_properties(${_target} PROPERTIES FRAMEWORK TRUE)
        install(TARGETS ${_target} FRAMEWORK DESTINATION ${LIB_INSTALL_DIR})
    endif ()
endmacro()

# FIXME Move into WEBKIT_FRAMEWORK after all libraries are using this macro
macro(WEBKIT_FRAMEWORK_TARGET _target)
    add_library(${_target}_PostBuild INTERFACE)
    target_link_libraries(${_target}_PostBuild INTERFACE ${${_target}_INTERFACE_LIBRARIES})
    target_include_directories(${_target}_PostBuild INTERFACE ${${_target}_INTERFACE_INCLUDE_DIRECTORIES})
    add_dependencies(${_target}_PostBuild ${${_target}_INTERFACE_DEPENDENCIES})
    if (NOT ${_target}_LIBRARY_TYPE STREQUAL "SHARED")
        target_compile_definitions(${_target}_PostBuild INTERFACE "STATICALLY_LINKED_WITH_${_target}")
    endif ()
    add_library(WebKit::${_target} ALIAS ${_target}_PostBuild)
endmacro()

macro(WEBKIT_EXECUTABLE _target)
    _WEBKIT_EXECUTABLE_LINK_FRAMEWORK(${_target})
    _WEBKIT_TARGET(${_target} ${_target})
    _WEBKIT_TARGET_ANALYZE(${_target})

    if (${_target}_OUTPUT_NAME)
        set_target_properties(${_target} PROPERTIES OUTPUT_NAME ${${_target}_OUTPUT_NAME})
    endif ()
    if (WIN32)
        if (WTF_CPU_X86)
            set(_processor_architecture "x86")
        elseif (WTF_CPU_X86_64)
            set(_processor_architecture "amd64")
        else ()
            set(_processor_architecture "*")
        endif ()
        target_link_options(${_target} PRIVATE "/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='${_processor_architecture}' publicKeyToken='6595b64144ccf1df' language='*'")
    endif ()
endmacro()

macro(WEBKIT_WRAP_EXECUTABLE _target)
    set(oneValueArgs TARGET_NAME)
    set(multiValueArgs SOURCES LIBRARIES)
    cmake_parse_arguments(opt "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (opt_TARGET_NAME)
        set(_wrapped_target_name ${opt_TARGET_NAME})
    else ()
        set(_wrapped_target_name ${_target}Lib)
    endif ()

    add_library(${_wrapped_target_name} SHARED "${CMAKE_BINARY_DIR}/cmakeconfig.h")

    _WEBKIT_EXECUTABLE_LINK_FRAMEWORK(${_target})
    _WEBKIT_TARGET(${_target} ${_wrapped_target_name})
    _WEBKIT_TARGET_ANALYZE(${_wrapped_target_name})

    # Unset values
    unset(${_target}_HEADERS)
    unset(${_target}_DEFINITIONS)
    unset(${_target}_PRIVATE_DEFINITIONS)
    unset(${_target}_INCLUDE_DIRECTORIES)
    unset(${_target}_SYSTEM_INCLUDE_DIRECTORIES)
    unset(${_target}_PRIVATE_INCLUDE_DIRECTORIES)
    unset(${_target}_PRIVATE_LIBRARIES)
    unset(${_target}_FRAMEWORKS)

    # Reset the sources
    set(${_target}_SOURCES ${opt_SOURCES})
    set(${_target}_LIBRARIES ${opt_LIBRARIES})
    set(${_target}_DEPENDENCIES ${_wrapped_target_name})
endmacro()

macro(WEBKIT_CREATE_FORWARDING_HEADER _target_directory _file)
    get_filename_component(_source_path "${CMAKE_SOURCE_DIR}/Source/" ABSOLUTE)
    get_filename_component(_absolute "${_file}" ABSOLUTE)
    get_filename_component(_name "${_file}" NAME)
    set(_target_filename "${_target_directory}/${_name}")

    # Try to make the path in the forwarding header relative to the Source directory
    # so that these forwarding headers are compatible with the ones created by the
    # WebKit2 generate-forwarding-headers script.
    string(REGEX REPLACE "${_source_path}/" "" _relative ${_absolute})

    set(_content "#include \"${_relative}\"\n")

    if (EXISTS "${_target_filename}")
        file(READ "${_target_filename}" _old_content)
    endif ()

    if (NOT _old_content STREQUAL _content)
        file(WRITE "${_target_filename}" "${_content}")
    endif ()
endmacro()

function(WEBKIT_MAKE_FORWARDING_HEADERS framework)
    set(options FLATTENED)
    set(oneValueArgs DESTINATION TARGET_NAME)
    set(multiValueArgs DIRECTORIES FILES)
    cmake_parse_arguments(opt "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(headers ${opt_FILES})
    file(MAKE_DIRECTORY ${opt_DESTINATION})
    foreach (dir IN LISTS opt_DIRECTORIES)
        file(GLOB files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${dir}/*.h)
        list(APPEND headers ${files})
    endforeach ()
    set(fwd_headers)
    foreach (header IN LISTS headers)
        if (IS_ABSOLUTE ${header})
            set(src_header ${header})
        else ()
            set(src_header ${CMAKE_CURRENT_SOURCE_DIR}/${header})
        endif ()
        if (opt_FLATTENED)
            get_filename_component(header_filename ${header} NAME)
            set(fwd_header ${opt_DESTINATION}/${header_filename})
        else ()
            get_filename_component(header_dir ${header} DIRECTORY)
            file(MAKE_DIRECTORY ${opt_DESTINATION}/${header_dir})
            set(fwd_header ${opt_DESTINATION}/${header})
        endif ()
        add_custom_command(OUTPUT ${fwd_header}
            COMMAND ${CMAKE_COMMAND} -E copy ${src_header} ${fwd_header}
            MAIN_DEPENDENCY ${header}
            VERBATIM
        )
        list(APPEND fwd_headers ${fwd_header})
    endforeach ()
    if (opt_TARGET_NAME)
        set(target_name ${opt_TARGET_NAME})
    else ()
        set(target_name ${framework}ForwardingHeaders)
    endif ()
    add_custom_target(${target_name} DEPENDS ${fwd_headers})
    add_dependencies(${framework} ${target_name})
endfunction()

function(WEBKIT_COPY_FILES target_name)
    set(options FLATTENED)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs FILES)
    cmake_parse_arguments(opt "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(files ${opt_FILES})
    set(dst_files)
    foreach (file IN LISTS files)
        if (IS_ABSOLUTE ${file})
            set(src_file ${file})
        else ()
            set(src_file ${CMAKE_CURRENT_SOURCE_DIR}/${file})
        endif ()
        if (opt_FLATTENED)
            get_filename_component(filename ${file} NAME)
            set(dst_file ${opt_DESTINATION}/${filename})
        else ()
            get_filename_component(file_dir ${file} DIRECTORY)
            file(MAKE_DIRECTORY ${opt_DESTINATION}/${file_dir})
            set(dst_file ${opt_DESTINATION}/${file})
        endif ()
        add_custom_command(OUTPUT ${dst_file}
            COMMAND ${CMAKE_COMMAND} -E copy ${src_file} ${dst_file}
            MAIN_DEPENDENCY ${file}
            VERBATIM
        )
        list(APPEND dst_files ${dst_file})
    endforeach ()
    add_custom_target(${target_name} ALL DEPENDS ${dst_files})
endfunction()

# Helper macros for debugging CMake problems.
macro(WEBKIT_DEBUG_DUMP_COMMANDS)
    set(CMAKE_VERBOSE_MAKEFILE ON)
endmacro()

macro(WEBKIT_DEBUG_DUMP_VARIABLES)
    set_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
       message(STATUS "${_variableName}=${${_variableName}}")
    endforeach ()
endmacro()

# Append the given flag to the target property.
# Builds on top of get_target_property() and set_target_properties()
macro(WEBKIT_ADD_TARGET_PROPERTIES _target _property _flags)
    get_target_property(_tmp ${_target} ${_property})
    if (NOT _tmp)
        set(_tmp "")
    endif (NOT _tmp)

    foreach (f ${_flags})
        set(_tmp "${_tmp} ${f}")
    endforeach (f ${_flags})

    set_target_properties(${_target} PROPERTIES ${_property} ${_tmp})
    unset(_tmp)
endmacro()

macro(WEBKIT_POPULATE_LIBRARY_VERSION library_name)
    if (NOT DEFINED ${library_name}_VERSION_MAJOR)
        set(${library_name}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    endif ()
    if (NOT DEFINED ${library_name}_VERSION_MINOR)
        set(${library_name}_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    endif ()
    if (NOT DEFINED ${library_name}_VERSION_MICRO)
        set(${library_name}_VERSION_MICRO ${PROJECT_VERSION_MICRO})
    endif ()
    if (NOT DEFINED ${library_name}_VERSION)
        set(${library_name}_VERSION ${PROJECT_VERSION})
    endif ()
endmacro()

macro(WEBKIT_CREATE_SYMLINK target src dest)
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ln -sf ${src} ${dest}
        DEPENDS ${dest}
        COMMENT "Create symlink from ${src} to ${dest}")
endmacro()
