string(REPLACE "." "_" VERSION ${VERSION})

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.akenotsuki.com/misc/srell/releases/srell${VERSION}.zip"
    FILENAME "srell${VERSION}.zip"
    SHA512 02d8292212ad570cc5fd37820c47097bef025b3f896a536ce9de2d3bd07bf961e6ab58d80caa216e40eaf0d75862f617010bae8bca7d2f424a81c832c8874697
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

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
