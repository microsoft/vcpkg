vcpkg_fail_port_install(ON_TARGET Android FreeBSD Linux OSX UWP)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 45ee22085d316088f94e45e5eee4229d67f0d550
    SHA512 7151b3ace107e02ba8257b58463af69eee5c2e379633578d5077c137574f0a2b74020db67401ab66ed6d2974d20cb07d5bed736e56baa3193b140af1248582c9
    HEAD_REF master
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

file(REMOVE_RECURSE ${SOURCE_PATH}/output)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/MemModLoader.sln
    TARGET build\\mmLoader-static
    PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    OPTIONS
        /p:ForceImportBeforeCppTargets=${SOURCE_PATH}/projects/mmLoader.static.props
)

if ("shellcode" IN_LIST FEATURES)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/MemModLoader.sln
        TARGET build\\mmLoader-shellcode-generator
        PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    )
endif()

file(GLOB mmLoader_HEADERS ${SOURCE_PATH}/output/include/mmLoader/*.h)
file(INSTALL ${mmLoader_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/mmLoader)

file(GLOB mmLoader_libs ${SOURCE_PATH}/output/lib/*.lib)

file(GLOB mmLoader_debug_lib ${SOURCE_PATH}/output/lib/*-d.lib)
file(INSTALL ${mmLoader_debug_lib} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

list(REMOVE_ITEM mmLoader_libs ${mmLoader_debug_lib})
file(INSTALL ${mmLoader_libs} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
