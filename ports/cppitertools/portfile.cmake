# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF 97bfd33cdc268426b20f189c13d3ed88f5e1f4c2
    SHA512 7b8926cf00b5be17fa89a1d1aea883e60848187bb00d637c40a20f6e11811add4785f2f461e530a6cd557d3be16490799ffcd7ea90bd7b58fdca549c3df03e8c
    HEAD_REF master
)

file(COPY
    ${SOURCE_PATH}/accumulate.hpp
    ${SOURCE_PATH}/chain.hpp
    ${SOURCE_PATH}/chunked.hpp
    ${SOURCE_PATH}/combinations.hpp
    ${SOURCE_PATH}/combinations_with_replacement.hpp
    ${SOURCE_PATH}/compress.hpp
    ${SOURCE_PATH}/count.hpp
    ${SOURCE_PATH}/cycle.hpp
    ${SOURCE_PATH}/dropwhile.hpp
    ${SOURCE_PATH}/enumerate.hpp
    ${SOURCE_PATH}/filter.hpp
    ${SOURCE_PATH}/filterfalse.hpp
    ${SOURCE_PATH}/groupby.hpp
    ${SOURCE_PATH}/imap.hpp
    ${SOURCE_PATH}/itertools.hpp
    ${SOURCE_PATH}/permutations.hpp
    ${SOURCE_PATH}/powerset.hpp
    ${SOURCE_PATH}/product.hpp
    ${SOURCE_PATH}/range.hpp
    ${SOURCE_PATH}/repeat.hpp
    ${SOURCE_PATH}/reversed.hpp
    ${SOURCE_PATH}/slice.hpp
    ${SOURCE_PATH}/sliding_window.hpp
    ${SOURCE_PATH}/sorted.hpp
    ${SOURCE_PATH}/starmap.hpp
    ${SOURCE_PATH}/takewhile.hpp
    ${SOURCE_PATH}/unique_everseen.hpp
    ${SOURCE_PATH}/unique_justseen.hpp
    ${SOURCE_PATH}/zip.hpp
    ${SOURCE_PATH}/zip_longest.hpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(COPY
    ${SOURCE_PATH}/internal/iter_tuples.hpp
    ${SOURCE_PATH}/internal/iterator_wrapper.hpp
    ${SOURCE_PATH}/internal/iteratoriterator.hpp
    ${SOURCE_PATH}/internal/iterbase.hpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/internal
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
