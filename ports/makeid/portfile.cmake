vcpkg_download_distfile(ARCHIVE
    URLS "https://www.humus.name/3D/MakeID.h"
    FILENAME "MakeID.h-${VERSION}"
    SHA512 fd4222d2cc0b0e16b0cfbac048cb64ac59d53ede10ab7f88f710e4b866cb67ffb0ec139821c181f1804a813cc9ab20cf33282c8b73e9ef0fdba414be474c2b64
)

file(INSTALL "${ARCHIVE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME "MakeID.h")

set(license_text 
"Public Domain

This file is released in the hopes that it will be useful. Use in whatever way you like, but no guarantees that it
actually works or fits any particular purpose. It has been unit-tested and benchmarked though, and seems to do
what it was designed to do, and seems pretty quick at it too."
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/makeid/copyright" "${license_text}")
