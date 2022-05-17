vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mikke89/RmlUi
	REF 4.4
	SHA512 b0c0a4c6cbc6892fe2ae5bbed21b672b7ec842de04347341925bd34712a37c84da4589578c6fbf1ab4ce8137b5530244f545d7c5bc1fbbd7ffa54eb83a6952d4
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
