vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/BehaviorTree/BehaviorTree.CPP/archive/3.5.1.tar.gz"
    FILENAME "BehaviorTree.CPP.3.5.1.tar.gz"
    SHA512 66db43225e692fa0f9073e63bdff765c037440372478792a9b442103a8bed945f5c3ae1d66266b86cb41d0006404a8297708a799ec0c7286c2beec6f964a4ac6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        001_port_fixes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(TOOLS bt3_log_cat bt3_plugin_manifest)

foreach(tool ${TOOLS})
    set(suffix ${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}"
                     DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
    endif()
endforeach()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_test_cmake(PACKAGE_NAME BehaviorTreeV3)
