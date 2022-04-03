if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "Discordcoreapi only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 31ce81f8583c1377bedc7131d303684e5c0af5fd
	SHA512 a9340d53d4c31e33aa9ab12aa0ce8b1aa997813a3609eac37906a42cbcbba4ba714c99b5d63573ab9e312a4ab4868ec6366871b63bfcb7f870c3efd576d4e9b9
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
message("${VCPKG_LIBRARY_LINKAGE}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
