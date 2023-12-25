vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mikke89/RmlUi
	REF 5.1
	SHA512 06bf1a24c6ff3f164ef1af80186d5f974e6a5467f6f0d50ec33bb14516e4899321fe7a5b9c4912def908a53711bf302bc782cf78117e0930862f5d1ad07dec18
	HEAD_REF master
	PATCHES
		add-robin-hood.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	FEATURES 
		lua             BUILD_LUA_BINDINGS
	INVERTED_FEATURES
		freetype        NO_FONT_INTERFACE_DEFAULT
)

# Remove built-in header, instead we use vcpkg version (from robin-hood-hashing port)
file(REMOVE ${SOURCE_PATH}/Include/RmlUi/Core/Containers/robin_hood.h)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	CONFIG_PATH  lib/RmlUi/cmake
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/RmlUi
	${CURRENT_PACKAGES_DIR}/lib/RmlUi
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/RmlUi/Core/Header.h
		"#if !defined RMLUI_STATIC_LIB"
		"#if 0"
	)
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/RmlUi/Debugger/Header.h
		"#if !defined RMLUI_STATIC_LIB"
		"#if 0"
	)
	if ("lua" IN_LIST FEATURES)
		vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/RmlUi/Lua/Header.h
			"#if !defined RMLUI_STATIC_LIB"
			"#if 0"
		)
	endif()
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
