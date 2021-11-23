
vcpkg_fail_port_install(MESSAGE "${PORT} currently supports only Windows Desktop" ON_TARGET "UWP" "OSX")

set(V "4.33")
vcpkg_download_distfile(ARCHIVE
    URLS "https://releases.mozilla.org/pub/nspr/releases/v${V}/src/nspr-${V}.tar.gz"
    FILENAME "nspr-${V}.tar.gz"
    SHA512 8064f826c977f1302a341ca7a7aaf7977b5d10102062c030b1d42b856638e3408ab262447e8c7cfd5a98879b9b1043d17ceae66fbb1e5ed86d6bc3531f26667e
)

set(OPTIONS )
if (VCPKG_TARGET_IS_WINDOWS)
	set(MOZBUILD_VERSION 3.3)
	vcpkg_download_distfile(MOZBUILD
		URLS "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-${MOZBUILD_VERSION}.exe"
		FILENAME "MozillaBuildSetup-${MOZBUILD_VERSION}.exe"
		SHA512 ac33d15dd9c974ef8ad581f9b414520a9d5e3b9816ab2bbf3e305d0a33356cc22c356cd9761e64a19588d17b6c13f124e837cfb462a36b8da898899e7db22ded
	)

	vcpkg_find_acquire_program(7Z)
	set(MOZBUILD_ROOT "${CURRENT_BUILDTREES_DIR}/mozbuild")
	file(MAKE_DIRECTORY "${MOZBUILD_ROOT}")
	vcpkg_execute_required_process(
		COMMAND ${7Z} x ${MOZBUILD} -y
		WORKING_DIRECTORY ${MOZBUILD_ROOT}
		LOGNAME extract-mozbuild.log
	)

	set(MOZBUILD_BINDIR "${MOZBUILD_ROOT}/bin")
	vcpkg_add_to_path(${MOZBUILD_BINDIR})

	set(MOZBUILD_MSYS_ROOT "${MOZBUILD_ROOT}/msys")
	vcpkg_add_to_path(PREPEND "${MOZBUILD_MSYS_ROOT}")

    set(ENV{CC}  "cl")
    set(ENV{CXX} "cl")
    set(ENV{LD}  "link")

    if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        list(APPEND OPTIONS "--disable-static-rtl")
    else()
        list(APPEND OPTIONS "--enable-static-rtl")
    endif()

    list(APPEND OPTIONS "--enable-win32-target=win95")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND OPTIONS "--enable-64bit")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND OPTIONS "--disable-64bit")
endif()

set(OPTIONS_DEBUG
    "--enable-debug-rtl"
)

set(OPTIONS_RELEASE
    "--disable-debug-rtl"
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF "${V}"
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    CONFIGURE_ENVIRONMENT_VARIABLES CC CXX LD
    PROJECT_SUBPATH "nspr"
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
    DISABLE_VERBOSE_FLAGS true
)
vcpkg_install_make()
vcpkg_copy_pdbs()

# VCPKG FHS adjustments - Linux
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# VCPKG FHS adjustments - Windows
file(GLOB BIN_RELEASE "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/lib/*.pdb")
list(LENGTH BIN_RELEASE BIN_RELEASE_SIZE)
if (BIN_RELEASE_SIZE GREATER 0)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")

    foreach(path ${BIN_RELEASE})
        get_filename_component(name "${path}" NAME)
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${name}" "${CURRENT_PACKAGES_DIR}/bin/${name}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")
endif()

file(GLOB BIN_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.pdb")
list(LENGTH BIN_DEBUG BIN_DEBUG_SIZE)
if (BIN_DEBUG_SIZE GREATER 0)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

    foreach(path ${BIN_DEBUG})
        get_filename_component(name "${path}" NAME)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${name}" "${CURRENT_PACKAGES_DIR}/debug/bin/${name}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

# Copy license
file(COPY "${SOURCE_PATH}/nspr/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nspr")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/nspr/LICENSE" "${CURRENT_PACKAGES_DIR}/share/nspr/copyright")
