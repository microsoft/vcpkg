vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cython/cython
    REF 0.29.17
    SHA512 f722e4feb0fcd0de7b882d0ba7cd78c37b6aaa4438619607665ea269b207a482fab6ca65cf12bab54d94b5929776c973a270c0748ed35b0f88a72811bf90d4df  
    HEAD_REF master
)

vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
