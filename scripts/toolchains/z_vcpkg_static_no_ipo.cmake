# windows.cmake and uwp.cmake make this file CMAKE_USER_MAKE_RULES_OVERRIDE for
# static library builds. CMake includes it for each language after the
# compiler's own rules, which is the earliest point the options below can be
# changed: the toolchain runs before CMake sets them.
#
# With INTERPROCEDURAL_OPTIMIZATION, MSVC compiles to LTCG IL (/GL) and clang-cl
# to LLVM bitcode, not to object code. Only the compiler version that wrote it
# can read that, so a static library holding it breaks the consumer's link as
# soon as the toolset is updated (MSVC fails with C1047). Keep the property, so
# that projects checking for it still configure, but make it add no options.

if(DEFINED Z_VCPKG_CHAINLOAD_USER_MAKE_RULES_OVERRIDE)
    include("${Z_VCPKG_CHAINLOAD_USER_MAKE_RULES_OVERRIDE}" RESULT_VARIABLE z_vcpkg_rules_override)
    # try_compile projects get this variable too, and run in another
    # directory, so keep the full path.
    set(Z_VCPKG_CHAINLOAD_USER_MAKE_RULES_OVERRIDE "${z_vcpkg_rules_override}")
    unset(z_vcpkg_rules_override)
endif()

foreach(z_vcpkg_lang IN ITEMS C CXX)
    if(DEFINED CMAKE_${z_vcpkg_lang}_COMPILE_OPTIONS_IPO)
        set(CMAKE_${z_vcpkg_lang}_COMPILE_OPTIONS_IPO "")
        set(CMAKE_${z_vcpkg_lang}_LINK_OPTIONS_IPO "")
        set(CMAKE_${z_vcpkg_lang}_CREATE_STATIC_LIBRARY_IPO "${CMAKE_${z_vcpkg_lang}_CREATE_STATIC_LIBRARY}")
    endif()
endforeach()
unset(z_vcpkg_lang)
