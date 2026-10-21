set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RandyGaul/cute_headers
    REF f3983ab42e4551881340e2fb7033a5d120cd6edd
    SHA512 08ef2ad162acd39408463da3c4c69325df742cf3e1afdb7508f6efaaab8ff8857a962489e6857e3f652eb8ab82ac0fdf9374cf1c11d6ee453a3000c3176c94c9
    HEAD_REF master
)

file(GLOB CUTE_HEADERS_FILES ${SOURCE_PATH}/*.h)
file(COPY ${CUTE_HEADERS_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
