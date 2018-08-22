if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  6)
set(PYTHON_VERSION_PATCH  4)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

include(vcpkg_common_functions)


if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_from_github(
        OUT_SOURCE_PATH TEMP_SOURCE_PATH
        REPO python/cpython
        REF v${PYTHON_VERSION}
        SHA512 32cca5e344ee66f08712ab5533e5518f724f978ec98d985f7612d0bd8d7f5cac25625363c9eead192faf1806d4ea3393515f72ba962a2a0bed26261e56d8c637
        HEAD_REF master
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0004-Fix-iomodule-for-RS4-SDK.patch
            ${CMAKE_CURRENT_LIST_DIR}/0005-Fix-DefaultWindowsSDKVersion.patch
    )

    # We need per-triplet directories because we need to patch the project files differently based on the linkage
    # Because the patches patch the same file, they have to be applied in the correct order
    set(SOURCE_PATH "${TEMP_SOURCE_PATH}-Lib-${VCPKG_LIBRARY_LINKAGE}-crt-${VCPKG_CRT_LINKAGE}")
    file(REMOVE_RECURSE ${SOURCE_PATH})
    file(RENAME "${TEMP_SOURCE_PATH}" ${SOURCE_PATH})

    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        vcpkg_apply_patches(
            SOURCE_PATH ${SOURCE_PATH}
            PATCHES
                ${CMAKE_CURRENT_LIST_DIR}/0001-Static-library.patch
        )
    endif()
    if (VCPKG_CRT_LINKAGE STREQUAL static)
        vcpkg_apply_patches(
            SOURCE_PATH ${SOURCE_PATH}
            PATCHES
                ${CMAKE_CURRENT_LIST_DIR}/0002-Static-CRT.patch
        )
    endif()

    if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(BUILD_ARCH "Win32")
        set(OUT_DIR "win32")
    elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(BUILD_ARCH "x64")
        set(OUT_DIR "amd64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
        PLATFORM ${BUILD_ARCH})

    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        vcpkg_apply_patches(
            SOURCE_PATH ${SOURCE_PATH}
            PATCHES
                ${CMAKE_CURRENT_LIST_DIR}/0003-Fix-header-for-static-linkage.patch
        )
    endif()

    file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
    file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})

    file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})

    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

else()
    #linux (maybe osx)
    set(VCPKG_LIBRARY_LINKAGE dynamic) # need to install python interpreter for boost-python to find 

    set(BASH bash) 

    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO python/cpython
        REF v${PYTHON_VERSION}
        SHA512 32cca5e344ee66f08712ab5533e5518f724f978ec98d985f7612d0bd8d7f5cac25625363c9eead192faf1806d4ea3393515f72ba962a2a0bed26261e56d8c637
        HEAD_REF master
    )

    # basing a lot of this off "x264/portfile.cmake" so maybe there is more here than needed... 
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-shared")
    else()
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static")
    endif()


    set(CONFIGURE_OPTIONS_RELEASE "--enable-optimizations --prefix=${CURRENT_PACKAGES_DIR}")

    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c 
            "${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELEASE}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "configure-${TARGET_TRIPLET}-rel"
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")


    set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug")

    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c 
            "${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME "configure-${TARGET_TRIPLET}-dbg")
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")


    # Build release ... 
    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c "make && make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "build-${TARGET_TRIPLET}-rel")
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")

    # Build debug ... 
    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c "make && make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME "build-${TARGET_TRIPLET}-dbg")
    message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

    # remove files that should not have been created... is there a way to configure build to avoid these???
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

vcpkg_copy_pdbs()
