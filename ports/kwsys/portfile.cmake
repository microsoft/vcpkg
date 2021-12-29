vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.kitware.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO utils/kwsys
    REF  dbc94f37f9821899aad441bcab525ad96a3f30dc #2021-08-06
    SHA512 98441866fd51f2d4d3974d3c37d4456ce9e50c6f6c2ab0691e55b268907611ef061562fc30b1baa42aa195caf2281aa0e1e0799abc545fe6dae70efe2050ea50
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DKWSYS_INSTALL_INCLUDE_DIR=${CURRENT_PACKAGES_DIR}/include
    OPTIONS_RELEASE
		-DKWSYS_INSTALL_BIN_DIR=${CURRENT_PACKAGES_DIR}/bin
		-DKWSYS_INSTALL_LIB_DIR=${CURRENT_PACKAGES_DIR}/lib
    OPTIONS_DEBUG
		-DKWSYS_INSTALL_BIN_DIR=${CURRENT_PACKAGES_DIR}/debug/bin
    -DKWSYS_INSTALL_LIB_DIR=${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_cmake_install()


# Handle copyright
file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
