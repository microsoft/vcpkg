find_program(vcpkg_configure_cmake_NINJA ninja)
function(vcpkg_configure_cmake)
    cmake_parse_arguments(_csc "" "SOURCE_PATH;GENERATOR" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if(_csc_GENERATOR)
        set(GENERATOR ${_csc_GENERATOR})
    elseif(TRIPLET_SYSTEM_NAME MATCHES "uwp" AND TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(GENERATOR "Visual Studio 14 2015")
    elseif(TRIPLET_SYSTEM_NAME MATCHES "uwp" AND TRIPLET_SYSTEM_ARCH MATCHES "x64")
        set(GENERATOR "Visual Studio 14 2015 Win64")
    elseif(TRIPLET_SYSTEM_NAME MATCHES "uwp" AND TRIPLET_SYSTEM_ARCH MATCHES "arm")
        set(GENERATOR "Visual Studio 14 2015 ARM")
    # elseif(NOT vcpkg_configure_cmake_NINJA MATCHES "NOTFOUND")
    #     set(GENERATOR "Ninja")
    elseif(TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(GENERATOR "Visual Studio 14 2015")
    elseif(TRIPLET_SYSTEM_ARCH MATCHES "x64")
        set(GENERATOR "Visual Studio 14 2015 Win64")
    elseif(TRIPLET_SYSTEM_ARCH MATCHES "arm")
        set(GENERATOR "Visual Studio 14 2015 ARM")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
            -G ${GENERATOR}
            -DCMAKE_VERBOSE_MAKEFILE=ON
            -DCMAKE_BUILD_TYPE=Release
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            -DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}
            -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
            -G ${GENERATOR}
            -DCMAKE_VERBOSE_MAKEFILE=ON
            -DCMAKE_BUILD_TYPE=Debug
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            -DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}/debug\\\\\\\;${CURRENT_INSTALLED_DIR}
            -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
endfunction()