if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/gemmlowp
    REF f9959600daa42992baace8a49544a00a743ce1b6
    SHA512 017966e3cb23cf27097e16a648e42aa7daa7032a4a62723ef86c66f51371d325680740e1fa54b54b207ad8de68525bf1384e42ab640daefd81b012a36ade2ea7
    HEAD_REF master
    PATCHES
        support-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/contrib"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
