vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/BehaviorTree/BehaviorTree.CPP/archive/3.5.6.tar.gz"
    FILENAME "BehaviorTree.CPP.3.5.6.tar.gz"
    SHA512 cd3b15eb7c5bab68239b697da166220b4df8dd7e6cf5e831f316d411e24be56c9ed74e54a3e3dd332164d740159eaf9ce62d005601fd65133809dab29430c9b7
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
