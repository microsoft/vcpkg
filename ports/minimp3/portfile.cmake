vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lieff/minimp3
    REF afb604c06bc8beb145fecd42c0ceb5bda8795144 # committed on 2021-11-30
    SHA512 633da0b20982f6f22c87d872c69626b2939ffb4519339cd0c090d7538308007cf633c07af57020cd2332a75c6e7b9bf3ebd5bda1af59dc96a4f0e85ce1b3f751
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/minimp3.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/minimp3_ex.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
