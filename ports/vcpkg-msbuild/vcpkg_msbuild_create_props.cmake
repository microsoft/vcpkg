function(vcpkg_msbuild_create_props)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        ""
        "OUTPUT_PROPS;LANGUAGE;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION"
        "DEPENDENT_PKGCONFIG;ADDITIONAL_LIBS_DEBUG;ADDITIONAL_LIBS_RELEASE"
    )

    if(NOT arg_OUTPUT_PROPS)
        message(FATAL_ERROR "'${CMAKE_CURRENT_FUNCTION}' requires option 'OUTPUT_PROPS'!")
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "'${CMAKE_CURRENT_FUNCTION}' was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT arg_LANGUAGE MATCHES "^(C|CXX|Fortran)$")
        # Fortran is probably very rare. 
        message(FATAL_ERROR "Option 'LANGUAGE' in '${CMAKE_CURRENT_FUNCTION}' needs to be set to one of C, CXX or Fortran")
    endif()

    # TODO: detect and set these ?
    #  <LanguageStandard>stdcpp20</LanguageStandard>
    #  <LanguageStandard_C>stdc17</LanguageStandard_C>
    if(NOT DEFINED arg_RELEASE_CONFIGURATION)
        set(arg_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED arg_DEBUG_CONFIGURATION)
        set(arg_DEBUG_CONFIGURATION Debug)
    endif()

    set(TARGET_PLATFORM_VERSION "")
    vcpkg_get_windows_sdk(TARGET_PLATFORM_VERSION)

    if(arg_DEPENDENT_PKGCONFIG)
        x_vcpkg_pkgconfig_get_modules(PREFIX MSBUILD INCLUDE_DIRS LIBRARIES LIBRARIES_DIR CFLAGS MODULES ${arg_DEPENDENT_PKGCONFIG})

        separate_arguments(MSBUILD_INCLUDE_DIRS_RELEASE WINDOWS_COMMAND "${MSBUILD_INCLUDE_DIRS_RELEASE}")
        separate_arguments(MSBUILD_INCLUDE_DIRS_DEBUG WINDOWS_COMMAND "${MSBUILD_INCLUDE_DIRS_DEBUG}")

        separate_arguments(MSBUILD_LIBRARIES_DIRS_RELEASE WINDOWS_COMMAND "${MSBUILD_LIBRARIES_DIRS_RELEASE}")
        separate_arguments(MSBUILD_LIBRARIES_DIRS_DEBUG WINDOWS_COMMAND "${MSBUILD_LIBRARIES_DIRS_DEBUG}")

        separate_arguments(MSBUILD_LIBRARIES_RELEASE WINDOWS_COMMAND "${MSBUILD_LIBRARIES_RELEASE}")
        separate_arguments(MSBUILD_LIBRARIES_DEBUG WINDOWS_COMMAND "${MSBUILD_LIBRARIES_DEBUG}")
    endif()
    vcpkg_cmake_get_vars(vars_file)
    include("${vars_file}")
    
    set(MSBUILD_COMPILER_FLAGS_RELEASE "${VCPKG_COMBINED_${arg_LANGUAGE}_FLAGS_RELEASE}")
    set(MSBUILD_COMPILER_FLAGS_DEBUG "${VCPKG_COMBINED_${arg_LANGUAGE}_FLAGS_DEBUG}")
    
    vcpkg_list(APPEND MSBUILD_INCLUDE_DIRS_RELEASE "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_list(APPEND MSBUILD_INCLUDE_DIRS_DEBUG "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_list(APPEND MSBUILD_LIBRARIES_DIRS_RELEASE "${CURRENT_INSTALLED_DIR}/lib")
    vcpkg_list(APPEND MSBUILD_LIBRARIES_DIRS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib")
    
    configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/vcpkg_msbuild.props.in" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vcpkg_msbuild.props")
    set(${arg_OUTPUT_PROPS} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/vcpkg_msbuild.props" PARENT_SCOPE)
endfunction()
