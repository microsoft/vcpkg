set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(key NOTFOUND)
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(key "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(key "Windows-${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(archive_path NOTFOUND)
# For convenient updates, use 
# vcpkg install vcpkg-tool-castxml --cmake-args=-DVCPKG_CASTXML_UPDATE=1
if(key STREQUAL "Linux-arm64" OR VCPKG_CASTXML_UPDATE)
    set(filename "castxml-${VERSION}-linux-aarch64.tar.gz")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/CastXML/CastXMLSuperbuild/releases/download/v${VERSION}/castxml-linux-aarch64.tar.gz"
		FILENAME "${filename}"
		SHA512 229d5339e217660f09dd87e2e639d666921a8c4e6c328a754dcae4290bba6bcac9d3b8e953814314ecdbf908d5d8e0d7dacbf1fdf6040a2e20d7acb98fb32f7d
	)
endif()
if(key STREQUAL "Linux-x64" OR VCPKG_CASTXML_UPDATE)
    set(filename "castxml-${VERSION}-linux.tar.gz")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/CastXML/CastXMLSuperbuild/releases/download/v${VERSION}/castxml-linux.tar.gz"
		FILENAME "${filename}"
		SHA512 592fcb6c7f85b6a1670cef7e0692ec6d1c9ba2e250825032ed6dcf9581aa169540eded608510aa1208ea1174df48c16390ee7daf7a17c7114d93a83a8a8e109b
	)
endif()
if(key STREQUAL "Darwin-arm64" OR VCPKG_CASTXML_UPDATE)
    set(filename "castxml-${VERSION}-macos-arm.tar.gz")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/CastXML/CastXMLSuperbuild/releases/download/v${VERSION}/castxml-macos-arm.tar.gz"
		FILENAME "${filename}"
		SHA512 4c8c969f7e53cd758b516bada449b322d37ad19d6d46602660d83ece20ce07f3d55462493382a1c422048928962fd33f9704638e2e41637d1147473562a55f94
	)
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Darwin-x64" OR VCPKG_CASTXML_UPDATE)
    set(filename "castxml-${VERSION}-macosx.tar.gz")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/CastXML/CastXMLSuperbuild/releases/download/v${VERSION}/castxml-macosx.tar.gz"
		FILENAME "${filename}"
		SHA512 c6986a796ab9a4f4deaf569534d628cc584088aa8b0e56026ea5ba19550b8ceeb41c34f46a85566a21205d6bb529717ee8944cfa9a9c7c27edb0504eece5544a
	)
    # Avoid breaking the code signature.
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()
if(key STREQUAL "Windows-x64" OR VCPKG_CASTXML_UPDATE)
    set(filename "castxml-${VERSION}-windows.zip")
    vcpkg_download_distfile(archive_path
		URLS "https://github.com/CastXML/CastXMLSuperbuild/releases/download/v${VERSION}/castxml-windows.zip"
		FILENAME "${filename}"
		SHA512 7c1970ad6f2e5f06a8704606db92df3400c4cd9716f88cac604924430c7e6865f8256a67282d28005714f0ed0a42f7f6e386f24ce80fb075371902d35674c6cc
	)
endif()
if(NOT archive_path)
	message(FATAL_ERROR "Unsupported platform '${key}'. Please implement me!")
endif()

if(VCPKG_CASTXML_UPDATE)
	message(STATUS "All downloads are up-to-date.")
	message(FATAL_ERROR "Stopping due to VCPKG_CASTXML_UPDATE being enabled.")
endif()

message(STATUS "archive_path: '${archive_path}'")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
vcpkg_execute_in_download_mode(
    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
)

vcpkg_install_copyright(
    FILE_LIST
        "${CURRENT_PACKAGES_DIR}/tools/castxml/share/doc/castxml/NOTICE"
        "${CURRENT_PACKAGES_DIR}/tools/castxml/share/doc/castxml/LICENSE"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/castxml/share/doc")
