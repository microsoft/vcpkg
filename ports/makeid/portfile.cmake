vcpkg_download_distfile(ARCHIVE
    URLS "https://www.humus.name/3D/MakeID.h"
    FILENAME "MakeID.h-${VERSION}"
    SHA512 9b7cb5c1b71904f37f65fcac3d18194154029fbe04d89099d879ce8eb03e796662c78653322317ed72988d3695414aaa6e6c24cfff999bea5009ec47119c57a7
)

file(COPY "${ARCHIVE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

set(license_text 
"Public Domain

This file is released in the hopes that it will be useful. Use in whatever way you like, but no guarantees that it
actually works or fits any particular purpose. It has been unit-tested and benchmarked though, and seems to do
what it was designed to do, and seems pretty quick at it too."
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/makeid/copyright" "${license_text}")
