vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/seacas
    REF 3595c0b21a1faaefc16a85bc21e54fc26d9ae937
    SHA512 5b5831e8e8d32d6e1b9e6be8d88b430175223da42e9951bd93f84b1cd4c358e8c2fab174bbf57e514bb9f6ce33d6e70d4c13ff6af49c9ea4402a7222411d3bfe
    HEAD_REF master
    PATCHES fix_tpl_libs.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
list(APPEND FEATURE_OPTIONS "-DTPL_ENABLE_DLlib:BOOL=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        #-DSeacas_ENABLE_Zoltan:BOOL=ON
        -DSeacas_ENABLE_SEACAS:BOOL=ON
        "-DSeacas_HOSTNAME:STRING=localhost"
        "-DSeacas_GENERATE_REPO_VERSION_FILE:BOOL=OFF"
        #"-DSeacas_ENABLE_ALL_PACKAGES:BOOL=ON"

)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASExodus" PACKAGE_NAME cmake/SEACASExodus DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASNemesis" PACKAGE_NAME cmake/SEACASNemesis DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASIoss" PACKAGE_NAME cmake/SEACASIoss DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASChaco" PACKAGE_NAME cmake/SEACASChaco DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASAprepro_lib" PACKAGE_NAME cmake/SEACASAprepro_lib DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASSuplibC" PACKAGE_NAME cmake/SEACASSuplibC DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASSuplibCpp" PACKAGE_NAME cmake/SEACASSuplibCpp DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASAprepro" PACKAGE_NAME cmake/SEACASAprepro DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASConjoin" PACKAGE_NAME cmake/SEACASConjoin DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASEjoin" PACKAGE_NAME cmake/SEACASEjoin DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASEpu" PACKAGE_NAME cmake/SEACASEpu DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASExodiff" PACKAGE_NAME cmake/SEACASExodiff DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASExo_format" PACKAGE_NAME cmake/SEACASExo_format DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASNas2exo" PACKAGE_NAME cmake/SEACASNas2exo DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASCpup" PACKAGE_NAME cmake/SEACASCpup DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASNemslice" PACKAGE_NAME cmake/SEACASNemslice DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACASNemspread" PACKAGE_NAME cmake/SEACASNemspread DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEACAS" PACKAGE_NAME cmake/SEACAS NO_PREFIX_CORRECTION )
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/external_packages" PACKAGE_NAME external_packages DO_NOT_DELETE_PARENT_CONFIG_PATH NO_PREFIX_CORRECTION )

vcpkg_copy_tools(TOOL_NAMES aprepro conjoin cth_pressure_map ejoin epu exodiff exo_format io_info io_modify io_shell nas2exo nem_slice nem_spread shell_to_hex skinner sphgen AUTO_CLEAN)

#TODO: Remove absolute paths in config

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Some scripts still in here
    # file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

