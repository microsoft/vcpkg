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
        002_fix_dependencies.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=1
        -DCMAKE_DISABLE_FIND_PACKAGE_Curses=1
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/BehaviorTreeV3/cmake TARGET_PATH share/behaviortreev3)
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/lib/BehaviorTreeV3"
    "${CURRENT_PACKAGES_DIR}/debug/lib/BehaviorTreeV3"
)
