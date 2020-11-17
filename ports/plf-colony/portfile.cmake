# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 7aba4b3f27e3dd7ca54cbe41738d04695d2c05e1
    SHA512 78dc8ee96174776e6993b03f15b1e7452864015641854ff89ffbe8d45e2203982347da9bf6eed1f7a0b40a794c53ab7c06e92eee101e4e0aae20997d240db872
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_colony.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
