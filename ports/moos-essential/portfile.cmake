set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/essential-moos
    REF b897ea86dba8b61412dc48ac0cfb5ff34cdaf5f6
    SHA512 7284744d211dcdcb0cd321eec96f3632ccda690e8894261f4f09a06bc8faefb2de68f4f2f755f4eeef5bb586044e98ac65cdd18c15193a1a4632bd2f4208c52f
    HEAD_REF master
    PATCHES
        fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES "pAntler" "pLogger" "pMOOSBridge" "pScheduler" "pShare" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "see moos-core for copyright\n")
