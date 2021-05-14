# Single-file header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO k06a/boolinq
    REF d8456eae92508d8a14fb209e8aa6dc1a1ae6b56d #v3.0.1
    SHA512 587d91c05cc2f3a900c2614832fe61f4c60b0ffe8ca3af273736ef7eaf6aa57185b9aa62906bf7d26beffd1fad3790b49107fe68c72d924509ca744212fdaee1
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/boolinq/boolinq.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/boolinq)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
