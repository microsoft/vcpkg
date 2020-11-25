include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slembcke/Chipmunk2D
    REF 87340c216bf97554dc552371bbdecf283f7c540e
    SHA512 9094017755e9c140aa5bf8a1b5502077ae4fb2b0a3e12f1114e86d8591a6188f89822ecc578a2b5e95f61c555018f1b3273fe50e833fe2daf30e94b180a3d07c
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    #architecture detection
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CHIPMUNK_ARCH Win32)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CHIPMUNK_ARCH x64)
    else()
    message(FATAL_ERROR "unsupported architecture")
    endif()

    #linking
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(CHIPMUNK_CONFIGURATION_SUFFIX " DLL")
    else()
        if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
            set(CHIPMUNK_CONFIGURATION_SUFFIX "")
        else()
            set(CHIPMUNK_CONFIGURATION_SUFFIX " SCRT")
        endif()
    endif()

    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/msvc/VS2015/chipmunk/chipmunk.vcxproj
        RELEASE_CONFIGURATION "Release${CHIPMUNK_CONFIGURATION_SUFFIX}"
        DEBUG_CONFIGURATION "Debug${CHIPMUNK_CONFIGURATION_SUFFIX}"
    )

    message(STATUS "Installing")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(INSTALL
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.dll"
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
        )
        file(INSTALL
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.dll"
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
            DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        )
    else()
        file(INSTALL
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
        file(INSTALL
            "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
    endif()

    file(INSTALL
        "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        "${SOURCE_PATH}/msvc/VS2015/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.lib"
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
else()
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS -DBUILD_DEMOS=OFF
                -DBUILD_SHARED=KEYSTONE_BUILD_SHARED
                -DBUILD_STATIC=KEYSTONE_BUILD_STATIC
                -DINSTALL_STATIC=KEYSTONE_BUILD_STATIC
    )

    vcpkg_install_cmake()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/libchipmunk.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/libchipmunk.dll")
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release) 
        file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/libchipmunk.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libchipmunk.dll")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

file(INSTALL
    ${SOURCE_PATH}/include/chipmunk
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/chipmunk RENAME copyright)

message(STATUS "Installing done")
