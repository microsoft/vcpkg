# srell uses calender versioning with underscore (e.g., 26_08), but vcpkg drops them in versions
string(REGEX REPLACE "^([0-9]+)\\.([1-9])$" "\\1_0\\2" SRELL_REF "${VERSION}")
string(REPLACE "." "_" SRELL_REF ${SRELL_REF})

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.akenotsuki.com/misc/srell/releases/srell${SRELL_REF}.zip"
    FILENAME "srell${SRELL_REF}.zip"
    SHA512 8c7bd80621e61a82d39a17a2f8967ce75e33b7f35a5ddd4a1f2dc067902081e16a25ff3ecf5dc4d7f420a3983c6ce462cb8621805c4deff678dc1307bec58ae8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL
    "${SOURCE_PATH}/srell.hpp"
    "${SOURCE_PATH}/srell_ucfdata2.h"
    "${SOURCE_PATH}/srell_updata3.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/license.txt"
    # The build produces Unicode-licensed generated headers.
    # The Unicode-license.txt file was downloaded from:
    # https://www.unicode.org/license.txt
    "${CURRENT_PORT_DIR}/Unicode-license.txt"
)
