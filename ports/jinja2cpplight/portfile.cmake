if(VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "jinja2cpplight doesn't support UWP.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughperkins/Jinja2CppLight
    REF 04196b080adf6edb86184824a1cf948ace310d19 #Commits on May 8, 2018 
    SHA512 30415da5ebc4fb805953cc9ff7e5fcd357d6fa1818c1ff2570b795252de6215562cd0f2f0418a1fa60e9d74b88339a3fea7166b898f54cface6ab1cfe3581bb5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()


file(GLOB_RECURSE JINJA2CPPLIGHT_EXES ${CURRENT_PACKAGES_DIR}/bin/jinja2cpplight_unittests*)
file(COPY ${JINJA2CPPLIGHT_EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE ${JINJA2CPPLIGHT_EXES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)