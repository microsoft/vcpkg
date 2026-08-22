string(REPLACE "." "_" VERSION ${VERSION})

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.akenotsuki.com/misc/srell/releases/srell${VERSION}.zip"
    FILENAME "srell${VERSION}.zip"
    SHA512 fe5d401944bbc544e558c76c9916d3065ec1737be93336295a7231a56f1f8772caa4710cfe67842aca8058fbcce5f7e2cb17e6064ff0d0443ce1c8046add0c21
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
