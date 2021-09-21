get_filename_component(BOOST_BUILD_INSTALLED_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(BOOST_BUILD_INSTALLED_DIR "${BOOST_BUILD_INSTALLED_DIR}" DIRECTORY)

function(boost_modular_build)
    cmake_parse_arguments(_bm "" "SOURCE_PATH;BOOST_CMAKE_FRAGMENT" "" ${ARGN})

    if(NOT DEFINED _bm_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to boost_modular_build.")
    endif()

    # Next CMake variables may be overridden in the file specified in ${_bm_BOOST_CMAKE_FRAGMENT}
    set(B2_OPTIONS)
    set(B2_OPTIONS_DBG)
    set(B2_OPTIONS_REL)
    set(B2_REQUIREMENTS) # this variable is used in the Jamroot.jam

    if(DEFINED _bm_BOOST_CMAKE_FRAGMENT)
        message(STATUS "Including ${_bm_BOOST_CMAKE_FRAGMENT}")
        include(${_bm_BOOST_CMAKE_FRAGMENT})
    endif()

    set(BOOST_BUILD_PATH "${BOOST_BUILD_INSTALLED_DIR}/tools/boost-build")

    if(EXISTS "${BOOST_BUILD_PATH}/b2.exe")
        set(B2_EXE "${BOOST_BUILD_PATH}/b2.exe")
    elseif(EXISTS "${BOOST_BUILD_PATH}/b2")
        set(B2_EXE "${BOOST_BUILD_PATH}/b2")
    else()
        message(FATAL_ERROR "Could not find b2 in ${BOOST_BUILD_PATH}")
    endif()

    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND B2_OPTIONS windows-api=store)
    endif()

    set(_bm_DIR ${BOOST_BUILD_INSTALLED_DIR}/share/boost-build)

    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(BOOST_LIB_PREFIX)
	if(VCPKG_PLATFORM_TOOLSET MATCHES "v14.")
	    set(BOOST_LIB_RELEASE_SUFFIX -vc140-mt.lib)
	    set(BOOST_LIB_DEBUG_SUFFIX -vc140-mt-gd.lib)
	elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v120")
	    set(BOOST_LIB_RELEASE_SUFFIX -vc120-mt.lib)
	    set(BOOST_LIB_DEBUG_SUFFIX -vc120-mt-gd.lib)
	endif()
    else()
        set(BOOST_LIB_PREFIX lib)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(BOOST_LIB_RELEASE_SUFFIX .a)
            set(BOOST_LIB_DEBUG_SUFFIX .a)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(BOOST_LIB_RELEASE_SUFFIX .dylib)
            set(BOOST_LIB_DEBUG_SUFFIX .dylib)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            set(BOOST_LIB_RELEASE_SUFFIX .dll.a)
            set(BOOST_LIB_DEBUG_SUFFIX .dll.a)
        else()
            set(BOOST_LIB_RELEASE_SUFFIX .so)
            set(BOOST_LIB_DEBUG_SUFFIX .so)
        endif()
    endif()

    if(EXISTS "${_bm_SOURCE_PATH}/build/Jamfile.v2")
        file(READ ${_bm_SOURCE_PATH}/build/Jamfile.v2 _contents)
        string(REGEX REPLACE
            "\.\./\.\./([^/ ]+)/build//(boost_[^/ ]+)"
            "/boost/\\1//\\2"
            _contents
            "${_contents}"
        )
        string(REGEX REPLACE " /boost//([^/ ]+)" " /boost/\\1//boost_\\1" _contents "${_contents}")
        file(WRITE ${_bm_SOURCE_PATH}/build/Jamfile.v2 "${_contents}")
    endif()

    function(unix_build BOOST_LIB_SUFFIX BUILD_TYPE BUILD_LIB_PATH)
        message(STATUS "Building ${BUILD_TYPE}...")
        set(BOOST_LIB_SUFFIX ${BOOST_LIB_SUFFIX})
        set(VARIANT ${BUILD_TYPE})
        set(BUILD_LIB_PATH ${BUILD_LIB_PATH})
        configure_file(${_bm_DIR}/Jamroot.jam ${_bm_SOURCE_PATH}/Jamroot.jam @ONLY)

        set(configure_option)
        if(DEFINED _bm_BOOST_CMAKE_FRAGMENT)
            list(APPEND configure_option "-DBOOST_CMAKE_FRAGMENT=${_bm_BOOST_CMAKE_FRAGMENT}")
        endif()

        vcpkg_configure_cmake(
            SOURCE_PATH ${BOOST_BUILD_INSTALLED_DIR}/share/boost-build
            PREFER_NINJA
            OPTIONS
                "-DPORT=${PORT}"
                "-DFEATURES=${FEATURES}"
                "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
                "-DB2_EXE=${B2_EXE}"
                "-DSOURCE_PATH=${_bm_SOURCE_PATH}"
                "-DBOOST_BUILD_PATH=${BOOST_BUILD_PATH}"
                "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
                ${configure_option}
        )
        vcpkg_install_cmake()

        vcpkg_copy_pdbs()
    endfunction()

    set(build_flag 0)
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        set(build_flag 1)
        set(VCPKG_BUILD_TYPE "release")
    endif()

    if(VCPKG_BUILD_TYPE STREQUAL "release")
        unix_build(${BOOST_LIB_RELEASE_SUFFIX} "release" "lib/")
    endif()

    if(build_flag)
        set(VCPKG_BUILD_TYPE "debug")
    endif()

    if(VCPKG_BUILD_TYPE STREQUAL "debug")
        unix_build(${BOOST_LIB_DEBUG_SUFFIX} "debug" "debug/lib/")
    endif()

    file(GLOB INSTALLED_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/*.lib ${CURRENT_PACKAGES_DIR}/lib/*.lib)
    foreach(LIB IN LISTS INSTALLED_LIBS)
        get_filename_component(OLD_FILENAME ${LIB} NAME)
        get_filename_component(DIRECTORY_OF_LIB_FILE ${LIB} DIRECTORY)
        string(REPLACE "libboost_" "boost_" NEW_FILENAME ${OLD_FILENAME})
        string(REPLACE "-s-" "-" NEW_FILENAME ${NEW_FILENAME}) # For Release libs
        string(REPLACE "-vc141-" "-vc140-" NEW_FILENAME ${NEW_FILENAME}) # To merge VS2017 and VS2015 binaries
        string(REPLACE "-vc142-" "-vc140-" NEW_FILENAME ${NEW_FILENAME}) # To merge VS2019 and VS2015 binaries
        string(REPLACE "-vc143-" "-vc140-" NEW_FILENAME ${NEW_FILENAME}) # To merge VS2022 and VS2015 binaries
        string(REPLACE "-sgd-" "-gd-" NEW_FILENAME ${NEW_FILENAME}) # For Debug libs
        string(REPLACE "-sgyd-" "-gyd-" NEW_FILENAME ${NEW_FILENAME}) # For Debug libs
        string(REPLACE "-x32-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-x64-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-a32-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-a64-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-1_76" "" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake > 3.10 to locate the binaries
        if("${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME}" STREQUAL "${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME}")
            # nothing to do
        elseif(EXISTS ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
            file(REMOVE ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME})
        else()
            file(RENAME ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME} ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
        endif()
    endforeach()

    # boost-regex[icu] and boost-locale[icu] generate has_icu.lib
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
    endif()

    if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/lib)
        message(FATAL_ERROR "No libraries were produced. This indicates a failure while building the boost library.")
    endif()

    configure_file(${BOOST_BUILD_INSTALLED_DIR}/share/boost-build/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
endfunction()
