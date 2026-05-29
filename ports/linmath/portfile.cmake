vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO datenwolf/linmath.h
    REF 3eef82841046507e16a0f6194a61cee2eadd34b3
    SHA512 cd8bc9c29b984cbb2fb1a1e743566e8f099d243c294658e84980cdbd83c881122f1abee68c50139ee9fddaa96f22f52eeae8e26dc86caa114cd11ebe5644a4db
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/linmath.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/linmath.h")

file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
