if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "Package only supports Linux platform.")
endif()

if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n  autoreconf libtool libudev\nThese can be installed on Ubuntu systems via apt-get install autoreconf libtool libudev-dev\n")
endif()

set(OPENSSH_VERSION "V_9_1_P1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openssh/openssh-portable
    REF ${OPENSSH_VERSION}
    SHA512 e1a6d44ceaca0f41b059706c58a38e6972d361f9b80acb0c9de243d5906e6b870f97ec170f3cdbc7f7749cd79f517f9a7c5c0379b64d90c5fd682336b0b8fb12
    HEAD_REF master
)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
	set(OPTIONS --disable-strip)
endif()

# This is general vcpkg configure. But this is not operating in Linux.
# because of autoconf fault in vcpkg_configure_make.
vcpkg_configure_make(
	SOURCE_PATH "${SOURCE_PATH}"
	AUTOCONFIG
	OPTIONS
		--prefix=${CURRENT_INSTALLED_DIR}
		--with-ssl-dir=${CURRENT_INSTALLED_DIR}
		--with-zlib=${CURRENT_INSTALLED_DIR}
		--with-privsep-path=${CURRENT_INSTALLED_DIR}/var/empty
		--with-mantype=man
		--with-mantype=cat
		--with-mantype=doc
		${OPTIONS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var/empty")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec")

file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)