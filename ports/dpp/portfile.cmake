vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO brainboxdotcc/DPP
	REF 9079c2846c73a41ee6f09f8fea5bb972ba559253
	SHA512 f43a284a3576f08b56e02bb355bac7bcbe34390be0e3c170b55bee63e518f22e8f85d00bf87d9c37baa950718e5b6e48fdafa5c075d84de62f6b8b98b5664a04
	HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/dpp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
