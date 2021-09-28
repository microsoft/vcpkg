set(VERSION 2_920)

vcpkg_download_distfile(
	ARCHIVE
	URLS "https://www.akenotsuki.com/misc/srell/srell${VERSION}.zip"
	FILENAME "srell${VERSION}.zip"
	SHA512 504BE3C24F497B8EA75D06787CBD3C8A475073F5881317D15619DFE6F7CBF4F75B9A81145981D1EE0F945C0D748C7BEDC60258DC52E4860FC7B769A01C9FA9FB
)

vcpkg_extract_source_archive(
	SOURCE_PATH
	ARCHIVE "${ARCHIVE}"
	NO_REMOVE_ONE_LEVEL
)

file(INSTALL
	"${SOURCE_PATH}/srell.hpp"
	"${SOURCE_PATH}/srell_ucfdata2.hpp"
	"${SOURCE_PATH}/srell_updata.hpp"
	DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
