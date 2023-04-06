include(${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre2-targets.cmake)

if ("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static" AND TARGET unofficial::pcre2::pcre2-8-static)
    add_library(unofficial::pcre2::pcre2 ALIAS unofficial::pcre2::pcre2-8-static)
elseif("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "dynamic" AND TARGET unofficial::pcre2::pcre2-8-shared)
    add_library(unofficial::pcre2::pcre2 ALIAS unofficial::pcre2::pcre2-8-shared)
endif()
