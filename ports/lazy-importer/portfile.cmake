# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/lazy_importer
    REF edac6afddb9e0df2e3affa8b2d631caafcba69ed
    SHA512 45f024c34fa1c8854b8b77706934ce95449b2416a5c1dcab970d0df068c9b5bf0de12994c13ac215e629f8ae21fdab75b4ce6535f56ca7508f490a4c664e5b1a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/lazy_importer.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
