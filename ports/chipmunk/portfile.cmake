include(vcpkg_common_functions)

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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slembcke/Chipmunk2D
    REF Chipmunk-7.0.2
    SHA512 3a697a73f854b36c53ea99390878094e91a44a0c6a19ebb0cd6726474b9b4f219085944efba4a7ae6faec1def3b9d58a02f159bea15724a7f5235bb645b91dba
    HEAD_REF master
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/msvc/vc14/chipmunk/chipmunk.vcxproj
    RELEASE_CONFIGURATION "Release${CHIPMUNK_CONFIGURATION_SUFFIX}"
    DEBUG_CONFIGURATION "Debug${CHIPMUNK_CONFIGURATION_SUFFIX}"
)

message(STATUS "Installing")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.dll"
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.dll"
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
else()
    file(INSTALL
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.pdb"
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

file(INSTALL
    "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Debug${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    "${SOURCE_PATH}/msvc/vc14/chipmunk/${CHIPMUNK_ARCH}/Release${CHIPMUNK_CONFIGURATION_SUFFIX}/chipmunk.lib"
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/include/chipmunk
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/chipmunk RENAME copyright)

message(STATUS "Installing done")
