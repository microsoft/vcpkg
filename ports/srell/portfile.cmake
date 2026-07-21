string(REPLACE "." "_" VERSION ${VERSION})

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://www.akenotsuki.com/misc/srell/releases/srell${VERSION}.zip"
    FILENAME "srell${VERSION}.zip"
    SHA512 08e4629daf31083db6799390f1a4c942fdcd21358e90568666e060c1d7563c878281c6e2f2bb6ebf9889bfc5606166d0664ff0b6b4657bbcbed18c42dbf707f5
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
