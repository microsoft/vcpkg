#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tetsurom/rxqt
    REF d0b15354199acbd409f39a2b6d30e539c1b05c94
    SHA512 151e6f9db3f7c98c47782c669eb40ec664ccad2fa33daf3ad035c6afcff89978835575f1160114e25fc23f62e7604565ec8ff88264020e6a88af456ed8e11faf
    HEAD_REF master
)

file(INSTALL
	${SOURCE_PATH}/include
    DESTINATION ${CURRENT_PACKAGES_DIR}
)

file(INSTALL
	${SOURCE_PATH}/LICENSE
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxqt RENAME copyright)