string(REPLACE "." "_" VERSION_NAME ${VERSION})
set(LIVEPP_FILE LPP_${VERSION_NAME}.zip)

vcpkg_download_distfile(
	ARCHIVE
    URLS https://liveplusplus.tech/downloads/${LIVEPP_FILE}
    FILENAME "${LIVEPP_FILE}"
    SHA512 07c5a9b30950d9c243d4fed671325e5e389e1e41e5c51feaa3d2cb7d64506f8baabf33f0c30851df8464a6c5f9fb15f11afac0c405ff8c4e513bc3034e63289d
)

vcpkg_download_distfile(
	LICENSE
    URLS https://liveplusplus.tech/downloads/LPP_EULA.pdf
    FILENAME LPP_EULA.pdf
    SHA512 19b435ab38e16c1c9527fd854c6a5643761819fc89367e7df76e9990b42af78eeff76ff3be172a6c0036a8428daf2f7a76b9e05c9c8b857bdee870a0045acbde
)

vcpkg_extract_source_archive(
	SOURCE_PATH
	ARCHIVE "${ARCHIVE}"
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" [[
    add_library(unofficial::livepp INTERFACE IMPORTED)
	set_target_properties(unofficial::livepp PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS LIVEPP_PATH=L"${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/livepp")
]])

file(INSTALL "${SOURCE_PATH}/API" DESTINATION "${CURRENT_PACKAGES_DIR}/include/LivePP" PATTERN "*.txt" EXCLUDE)
file(INSTALL "${SOURCE_PATH}/Agent" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/Broker" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/CLI" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${LICENSE}")
