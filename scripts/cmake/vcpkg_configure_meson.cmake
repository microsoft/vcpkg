function(vcpkg_configure_meson)
    cmake_parse_arguments(_vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})
    
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    
    # use the same compiler options as in vcpkg_configure_cmake
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        if(NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME OR _TARGETTING_UWP)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
        endif()
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    
    set(MESON_COMMON_CFLAGS "${MESON_COMMON_CFLAGS} ${CMAKE_C_FLAGS}")
    set(MESON_COMMON_CXXFLAGS "${MESON_COMMON_CXXFLAGS} ${CMAKE_CXX_FLAGS}")
    
    set(MESON_DEBUG_CFLAGS "${MESON_DEBUG_CFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    set(MESON_DEBUG_CXXFLAGS "${MESON_DEBUG_CXXFLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")

    set(MESON_RELEASE_CFLAGS "${MESON_RELEASE_CFLAGS} ${CMAKE_C_FLAGS_RELEASE}")
    set(MESON_RELEASE_CXXFLAGS "${MESON_RELEASE_CXXFLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
    
    if(VCPKG_TARGET_IS_WINDOWS)
        set(MESON_COMMON_LDFLAGS "${MESON_COMMON_LDFLAGS} /DEBUG")
        set(MESON_RELEASE_LDFLAGS "${MESON_RELEASE_LDFLAGS} /INCREMENTAL:NO /OPT:REF /OPT:ICF")
    endif()
    
    # select meson cmd-line options
    #list(APPEND _vcm_OPTIONS -Dcmake_prefix_path=${CURRENT_INSTALLED_DIR})
    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja --wrap-mode nodownload)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND _vcm_OPTIONS --default-library shared)
    else()
        list(APPEND _vcm_OPTIONS --default-library static)
    endif()
    
    list(APPEND _vcm_OPTIONS_DEBUG --prefix ${CURRENT_PACKAGES_DIR}/debug --includedir ../include)
    list(APPEND _vcm_OPTIONS_RELEASE --prefix  ${CURRENT_PACKAGES_DIR})
    
    vcpkg_find_acquire_program(MESON)
    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)

    vcpkg_add_to_path("${NINJA_PATH}")
    
    # configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        set(ENV{CFLAGS} "${MESON_COMMON_CFLAGS} ${MESON_RELEASE_CFLAGS}")
        set(ENV{CXXFLAGS} "${MESON_COMMON_CXXFLAGS} ${MESON_RELEASE_CXXFLAGS}")
        set(ENV{LDFLAGS} "${MESON_COMMON_LDFLAGS} ${MESON_RELEASE_LDFLAGS}")
        set(ENV{CPPFLAGS} "${MESON_COMMON_CPPFLAGS} ${MESON_RELEASE_CPPFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_RELEASE} ${_vcm_SOURCE_PATH}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        # configure debug
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(ENV{CFLAGS} "${MESON_COMMON_CFLAGS} ${MESON_DEBUG_CFLAGS}")
        set(ENV{CXXFLAGS} "${MESON_COMMON_CXXFLAGS} ${MESON_DEBUG_CXXFLAGS}")
        set(ENV{LDFLAGS} "${MESON_COMMON_LDFLAGS} ${MESON_DEBUG_LDFLAGS}")
        set(ENV{CPPFLAGS} "${MESON_COMMON_CPPFLAGS} ${MESON_DEBUG_CPPFLAGS}")
        vcpkg_execute_required_process(
            COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_DEBUG} ${_vcm_SOURCE_PATH}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

endfunction()
