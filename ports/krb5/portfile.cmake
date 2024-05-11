vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO krb5/krb5
	REF "krb5-${VERSION}-final"
	SHA512 184ef8645d7e17f30a8e3d4005364424d2095b3d0c96f26ecef0c2dd2f3a096a0dd40558ed113121483717e44f6af41e71be0e5e079c76a205535d0c11a2ea34
	PATCHES relative_paths.patch
)

if ("${VCPKG_TARGET_IS_OSX}")
	# Required for recent macOS and static build: https://mailman.mit.edu/pipermail/krbdev/2024-January/013653.html
	if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
		set(LD_FLAGS "-framework Kerberos")
	endif ()
	set(EXTRA_OPTIONS
		"--disable-nls"
		"--disable-silent-rules"
		"--without-system-verto"
		"--without-keyutils"
	)
endif ()

vcpkg_configure_make(
	SOURCE_PATH "${SOURCE_PATH}"
	PROJECT_SUBPATH src
	AUTOCONFIG
	NO_ADDITIONAL_PATHS
	DETERMINE_BUILD_TRIPLET
	OPTIONS
		--disable-rpath
		"CFLAGS=-fcommon \$CFLAGS"
		"LDFLAGS=${LD_FLAGS}"
    ${EXTRA_OPTIONS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(
	SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin"
	DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
	TOOL_NAMES
		gss-client
		kadmin
		kdestroy
		kinit
		klist
		kpasswd
		kswitch
		ktutil
		kvno
		sclient
		sim_client
		uuclient
		compile_et
		k5srvutil
		krb5-config
	AUTO_CLEAN
)

vcpkg_copy_tools(
	SEARCH_DIR "${CURRENT_PACKAGES_DIR}/sbin"
	DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/sbin"
	TOOL_NAMES
		gss-server
		kadmind
		kdb5_util
		kprop
		kpropd
		kproplog
		krb5kdc
		sim_server
		sserver
		uuserver
		kadmin.local
		krb5-send-pr
)

# Required because AUTO_CLEAN doesn't work with sbin
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/sbin")

# Empty directories
file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug"
	"${CURRENT_PACKAGES_DIR}/share/man"
	"${CURRENT_PACKAGES_DIR}/var"
)

# Also empty when static
if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/krb5")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE")
