vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WG21-SG14/SG14
    REF 836e4d202249a86ba5ff56139c35e0afa60e7a1c
    SHA512 002a6b83ecfb41bde978e912feda77639460ff376ad634e1cd0a908e2be35863489132db579d399bb6e5087fcb0355a222e611eae58eb0c2d8372bdd25f60e07
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/SG14 DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright

file(STRINGS "${SOURCE_PATH}/SG14/flat_map.h" SOURCE_LINES)
list(SUBLIST SOURCE_LINES 0 26 SOURCE_LINES)
list(JOIN SOURCE_LINES "\n" _contents)

file(READ "${SOURCE_PATH}/Docs/plf_licensing.txt" plf_licensing_contents)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}\n${plf_licensing_contents}")
