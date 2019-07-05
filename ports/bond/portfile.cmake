include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-7.0.2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/bond
    REF  8.1.0
    SHA512 287a2d299036b57e0576903b1f5372bf8071243ada57153c4bf231cdc660faab1e70c60ddde57ac759d941b74af4ba25d81a5d58e8dbf391032b7b226c4cd18c
    HEAD_REF master
    PATCHES fix-install-path.patch
)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_download_distfile(GBC_ARCHIVE
    URLS "https://github.com/microsoft/bond/releases/download/8.1.0/gbc-8.1.0-amd64.zip"
    FILENAME "gbc-8.1.0-amd64.zip"
    SHA512 896c9a78fc714e0ea44c37ed36400ec8e5f52d495a8d81aa80834ff6cd6303c7c94e06129f7b2269416a9e0ffb61423e87406db798fb5be7ff00f14981530089
    )
    
    # Extract the precompiled gbc
    vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
    set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc.exe)

    if (NOT EXISTS "${FETCHED_GBC_PATH}")
        message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exists, but it doesn't.")
    endif()
    
else()
    message(STATUS "Installing stack...")
    vcpkg_download_distfile(
        ARCHIVE
        URLS "https://get.haskellstack.org/"
        FILENAME "stack-install.sh"
        SHA512 6db2008297416ad856aa498908bf695737cf3cc466440397720a458358e9661d07abdba762662080ee8bbd8171cdcb05eec6d3696382575c099adfb8427e05fd
    )
    
    set(BASH /bin/bash)
    
    vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc "${ARCHIVE}" -f
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-stack
    )
    
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBOND_LIBRARIES_ONLY=TRUE
    -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
    -DBOND_SKIP_GBC_TESTS=TRUE
    -DBOND_ENABLE_COMM=FALSE
    -DBOND_ENABLE_GRPC=FALSE
    -DBOND_FIND_RAPIDJSON=TRUE
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/bond TARGET_PATH share/bond)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bond)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bond/LICENSE ${CURRENT_PACKAGES_DIR}/share/bond/copyright)

# There's no way to supress installation of the headers in the debug build,
# so we just delete them.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
