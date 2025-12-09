# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_queue
    REF 1fb9d87a210f7813450ee54a469f9f79ea4ec872
    SHA512 bca6662f5b0c4dfad4b9c1192aced83cf379ed2f115b498ad98003b7201fa80cf00ee697c7c8f9a8f9fe7c979207a8e99dd58549e124ea041af25c9217d7ae6f 
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/plf_queue.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
