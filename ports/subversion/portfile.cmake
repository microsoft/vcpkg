vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/subversion
    REF f9f57162357a0be89f4e07bf0c011b7c3c79e453
    SHA512 e7329594a793625aa2bde8016b81fbf899e95b69a678fef244f621808dd2685e5ff39b39dc1775fb86e2ce8356d09821aa3e6f89159b2f6d17eff86c1de65a80
    HEAD_REF trunk
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" gen-make.py -t cmake
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME gen-make-${TARGET_TRIPLET}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES 
    svn
    svnadmin
    svnbench
    svndumpfilter
    svnfsfs
    svnlook
    svnmucc
    svnrdump
    svnserve
    svnsync
    svnversion
    AUTO_CLEAN
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-subversion-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-subversion"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")