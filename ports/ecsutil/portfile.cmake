if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ECSUtil_CONFIGURATION_RELEASE Release)
    set(ECSUtil_CONFIGURATION_DEBUG Debug)
else()
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(ECSUtil_CONFIGURATION_RELEASE "Release Lib")
        set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib")
    else()
        set(ECSUtil_CONFIGURATION_RELEASE "Release Lib Static")
        set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib Static")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EMCECS/ecs-object-client-windows-cpp
    REF af9fd3cc0be5eacfeb431ca4607d3b73dd318353 # v1.0.7.15
    SHA512 091f4b4870d5bdcbd46c35b2d75e927c9da69e2aba9a24b36504ab9fa3e33fba6eec2a8a5b649fc3ad793e3043c3f2702b753341f74d87de1a7f96c251839c69
    HEAD_REF master
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH ECSUtil.sln
    PLATFORM "${TRIPLET_SYSTEM_ARCH}" # This means x86 as platform config instead of Win32
    TARGET ECSUtil
    RELEASE_CONFIGURATION "${ECSUtil_CONFIGURATION_RELEASE}"
    DEBUG_CONFIGURATION "${ECSUtil_CONFIGURATION_DEBUG}"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY "${SOURCE_PATH}/ECSUtil" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/ECSUtil/res" "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/NatvisAddIn.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/NatvisAddIn.dll")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
