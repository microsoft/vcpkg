vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "ANDROID" "FREEBSD" "OPENBSD")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH  SOURCE_PATH
    REPO renestein/Rstein.AsyncCpp
    REF 0.0.6
    SHA512 ba49d244eb294a907a7dab087c27120c7b2c36c89b150314b456b504eaaf3cc01125e66418ecf9f21b58468282f32dd637e252c5146c6e31fd8f87e98c87d7ab
    HEAD_REF master
)

if("lib-cl-win-legacy-await" IN_LIST FEATURES)
    set(RELEASE_CONFIGURATION  "Release_VSAWAIT")
    set(DEBUG_CONFIGURATION    "Debug_VSAWAIT")
else()
    set(RELEASE_CONFIGURATION "Release")
    set(DEBUG_CONFIGURATION   "Debug")
endif()

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "x86")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()


vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH RStein.AsyncCppLib.sln
    LICENSE_SUBPATH LICENSE    
    PLATFORM ${MSBUILD_PLATFORM}
    DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
    RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}    
)

file(COPY "${SOURCE_PATH}/RStein.AsyncCpp/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/asynccpp"
    FILES_MATCHING PATTERN "*.h")