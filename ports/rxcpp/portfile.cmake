#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/RxCpp-3.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Reactive-Extensions/RxCpp/archive/v3.0.0.tar.gz"
    FILENAME "v3.0.0.tar.gz"
    SHA512 6d810b6163d0920d531f32a13729e290c81b47d5fc9c3e3d3d8a25d27a6f0671fec097d091bef7383b7e556e9e5471db087bb955e7f4fd9a5fdc9e7b06050844
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL
	${SOURCE_PATH}/Rx/v2/src/rxcpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/Ix/CPP/src/cpplinq
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/license.md
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxcpp RENAME copyright)