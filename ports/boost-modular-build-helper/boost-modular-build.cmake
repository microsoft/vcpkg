include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-cmake/vcpkg-port-config.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-cmake-get-vars/vcpkg-port-config.cmake")

get_filename_component(BOOST_BUILD_INSTALLED_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(BOOST_BUILD_INSTALLED_DIR "${BOOST_BUILD_INSTALLED_DIR}" DIRECTORY)

set(BOOST_VERSION 1.82.0)
string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" BOOST_VERSION_MATCH "${BOOST_VERSION}")
if("${CMAKE_MATCH_3}" GREATER 0)
    set(BOOST_VERSION_ABI_TAG "${CMAKE_MATCH_1}_${CMAKE_MATCH_2}_${CMAKE_MATCH_3}")
else()
    set(BOOST_VERSION_ABI_TAG "${CMAKE_MATCH_1}_${CMAKE_MATCH_2}")
endif()

function(boost_modular_build)
    cmake_parse_arguments(_bm "" "SOURCE_PATH;BOOST_CMAKE_FRAGMENT" "" ${ARGN})

    if(NOT DEFINED _bm_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to boost_modular_build.")
    endif()

    # The following variables are used in the Jamroot.jam
    set(B2_REQUIREMENTS)

    # Some CMake variables may be overridden in the file specified in ${_bm_BOOST_CMAKE_FRAGMENT}
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
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(BOOST_LIB_PREFIX lib)
    endif()
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(BOOST_LIB_RELEASE_SUFFIX .lib)
        set(BOOST_LIB_DEBUG_SUFFIX .lib)
    else()
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
            set(BOOST_LIB_RELEASE_SUFFIX .a)
            set(BOOST_LIB_DEBUG_SUFFIX .a)
        elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
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

    set(_jamfile)
    if(EXISTS "${_bm_SOURCE_PATH}/build/Jamfile.v2")
        set(_jamfile "${_bm_SOURCE_PATH}/build/Jamfile.v2")
    elseif(EXISTS "${_bm_SOURCE_PATH}/build/Jamfile")
        set(_jamfile "${_bm_SOURCE_PATH}/build/Jamfile")
    endif()
    if(_jamfile)
        file(READ "${_jamfile}" _contents)
        string(REGEX REPLACE
            "\.\./\.\./([^/ ]+)/build//(boost_[^/ ]+)"
            "/boost/\\1//\\2"
            _contents
            "${_contents}"
        )
        string(REGEX REPLACE "/boost//([^/ ]+)" "/boost/\\1//boost_\\1" _contents "${_contents}")
        file(WRITE "${_jamfile}" "${_contents}")
    endif()

    if("python2" IN_LIST FEATURES)
        # Find Python2 in the current installed directory
        file(GLOB python2_include_dir "${CURRENT_INSTALLED_DIR}/include/python2.*")
        string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python2_version "${python2_include_dir}")
        string(REPLACE "." "" PYTHON_VERSION_TAG "${python2_version}")
    endif()
    if("python3" IN_LIST FEATURES)
        # Find Python3 in the current installed directory
        file(GLOB python3_include_dir "${CURRENT_INSTALLED_DIR}/include/python3.*")
        string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python3_version "${python3_include_dir}")
        string(REPLACE "." "" PYTHON_VERSION_TAG "${python3_version}")
    endif()

    configure_file(${BOOST_BUILD_INSTALLED_DIR}/share/boost-build/Jamroot.jam.in ${_bm_SOURCE_PATH}/Jamroot.jam @ONLY)

    set(configure_options)
    if(_bm_BOOST_CMAKE_FRAGMENT)
        list(APPEND configure_options "-DBOOST_CMAKE_FRAGMENT=${_bm_BOOST_CMAKE_FRAGMENT}")
    endif()

    vcpkg_cmake_get_vars(cmake_vars_file)

    vcpkg_check_features(
        OUT_FEATURE_OPTIONS feature_options
        FEATURES
            python2 WITH_PYTHON2
            python3 WITH_PYTHON3
    )

    vcpkg_cmake_configure(
        SOURCE_PATH "${BOOST_BUILD_INSTALLED_DIR}/share/boost-build"
        GENERATOR Ninja
        OPTIONS
            "-DPORT=${PORT}"
            "-DFEATURES=${FEATURES}"
            ${feature_options}
            "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
            "-DB2_EXE=${B2_EXE}"
            "-DSOURCE_PATH=${_bm_SOURCE_PATH}"
            "-DBOOST_BUILD_PATH=${BOOST_BUILD_PATH}"
            "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
            "-DVCPKG_CMAKE_VARS_FILE=${cmake_vars_file}"
            "-DVCPKG_CONCURRENCY=${VCPKG_CONCURRENCY}"
            ${configure_options}
        MAYBE_UNUSED_VARIABLES
            FEATURES
    )

    vcpkg_cmake_install()

    vcpkg_copy_pdbs(
        BUILD_PATHS
            "${CURRENT_PACKAGES_DIR}/bin/*.dll"
            "${CURRENT_PACKAGES_DIR}/bin/*.pyd"
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.pyd"
    )

    # boost-regex[icu] and boost-locale[icu] generate has_icu.lib
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
    endif()

    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/lib")
        message(FATAL_ERROR "No libraries were produced. This indicates a failure while building the boost library.")
    endif()

    configure_file(${BOOST_BUILD_INSTALLED_DIR}/share/boost-build/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
endfunction()
