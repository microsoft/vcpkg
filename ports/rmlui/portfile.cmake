vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mikke89/RmlUi
	REF 5.0
	SHA512 10136893eb695b098fe6d718e23ce331c549faf3eb73413a5bb143ddd3601726b8bc42382c4e575d2abfff838ad3e6af1d4945426223a9c6f0fd048b481819dd
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
