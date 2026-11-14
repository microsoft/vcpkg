# Validate automatically discovered fallback compilers after project() has enabled
# its languages. This avoids rejecting a compiler for a language the project does
# not use.
if(_VCPKG_MINGW_PREVIOUS_PROJECT_INCLUDE)
    foreach(_vcpkg_mingw_project_include IN LISTS _VCPKG_MINGW_PREVIOUS_PROJECT_INCLUDE)
        include("${_vcpkg_mingw_project_include}")
    endforeach()
endif()

get_property(_VCPKG_MINGW_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)

list(FIND _VCPKG_MINGW_ENABLED_LANGUAGES "C" _VCPKG_MINGW_C_LANGUAGE_INDEX)
if(NOT _VCPKG_MINGW_C_LANGUAGE_INDEX EQUAL -1
    AND _VCPKG_MINGW_C_FALLBACK_COMPILER
    AND CMAKE_C_COMPILER STREQUAL _VCPKG_MINGW_C_FALLBACK_COMPILER)
    _vcpkg_validate_mingw_compiler(
        "${CMAKE_C_COMPILER}"
        "C"
        "${_VCPKG_MINGW_TARGET_REGEX}"
    )
endif()

list(FIND _VCPKG_MINGW_ENABLED_LANGUAGES "CXX" _VCPKG_MINGW_CXX_LANGUAGE_INDEX)
if(NOT _VCPKG_MINGW_CXX_LANGUAGE_INDEX EQUAL -1
    AND _VCPKG_MINGW_CXX_FALLBACK_COMPILER
    AND CMAKE_CXX_COMPILER STREQUAL _VCPKG_MINGW_CXX_FALLBACK_COMPILER)
    _vcpkg_validate_mingw_compiler(
        "${CMAKE_CXX_COMPILER}"
        "C++"
        "${_VCPKG_MINGW_TARGET_REGEX}"
    )
endif()
