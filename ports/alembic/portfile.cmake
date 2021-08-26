vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "OSX" "Linux")

vcpkg_buildpath_length_warning(37)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF 7e5cf9b896f4299117457f36a7bf47d962cd0ebf # 1.7.16
    SHA512 aeb449890874fa3a89a72245f3e63a3370332d6becdf20bc77bd9c216bbe1e4578018bbe559c06df69db199799d071399f925a91c8fa816e0eec2d2420f091e9
    HEAD_REF master
    PATCHES
        fix-find-openexr-ilmbase.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindIlmBase.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindOpenEXR.cmake)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # In debug mode with g++, alembic defines -Werror
    # so we need to disable some warnings to avoid build errors
    list(APPEND GXX_DEBUG_FLAGS
        -DCMAKE_CXX_FLAGS_DEBUG=-Wno-deprecated
        -DCMAKE_CXX_FLAGS_DEBUG=-Wno-error=implicit-fallthrough
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_HDF5=ON
    OPTIONS_DEBUG
        ${GXX_DEBUG_FLAGS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Alembic)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_TARGET_IS_WINDOWS)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")

        file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
        file(REMOVE ${EXE})
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/bin/Alembic.dll)
        file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-release.cmake RELEASE_CONFIG)
        string(REPLACE "\${_IMPORT_PREFIX}/lib/Alembic.dll"
                    "\${_IMPORT_PREFIX}/bin/Alembic.dll" RELEASE_CONFIG "${RELEASE_CONFIG}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-release.cmake "${RELEASE_CONFIG}")

    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")

        file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
        file(REMOVE ${DEBUG_EXE})
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/debug/bin/Alembic.dll)
        file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-debug.cmake DEBUG_CONFIG)
        string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/Alembic.dll"
                    "\${_IMPORT_PREFIX}/debug/bin/Alembic.dll" DEBUG_CONFIG "${DEBUG_CONFIG}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-debug.cmake "${DEBUG_CONFIG}")
        
    endif()

else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
