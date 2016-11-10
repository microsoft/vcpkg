#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/RxCpp-2.3.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Reactive-Extensions/RxCpp/archive/v2.3.0.tar.gz"
    FILENAME "RxCpp-2.3.0.tar.gz"
    SHA512 180cf36777b0c14e989b4b79f01fcda7ecabfe4b3cee3ad7343138497578af02745de63f74941ec228eac3fccca4a7dfdfdd1c4d16a89438022dca6f9968953f
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

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