set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(ascii_tarball_directory "${CURRENT_BUILDTREES_DIR}/ascii-tarball")
set(bmp_tarball_directory "${CURRENT_BUILDTREES_DIR}/bmp-tarball")
set(nonbmp_tarball_directory "${CURRENT_BUILDTREES_DIR}/nonbmp-tarball")

file(REMOVE_RECURSE
    "${ascii_tarball_directory}"
    "${bmp_tarball_directory}"
    "${nonbmp_tarball_directory}"
)
file(MAKE_DIRECTORY
    "${ascii_tarball_directory}"
    "${bmp_tarball_directory}"
    "${nonbmp_tarball_directory}"
)

file(TOUCH
    "${ascii_tarball_directory}/foo"
    "${ascii_tarball_directory}/bar"
    "${ascii_tarball_directory}/baz"
)
file(TOUCH
    "${bmp_tarball_directory}/foo"
    "${bmp_tarball_directory}/βαρ"
    "${bmp_tarball_directory}/包子"
)
file(TOUCH
    "${nonbmp_tarball_directory}/foo"
    "${nonbmp_tarball_directory}/𐌁𐌀𐌓"
    "${nonbmp_tarball_directory}/🙈🤟🏼"
)

foreach(dir IN ITEMS ascii bmp nonbmp)
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E tar czf
            "${${dir}_tarball_directory}.tar.gz"
            "${${dir}_tarball_directory}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "compress-${dir}"
    )

    vcpkg_extract_source_archive(source_path
        ARCHIVE "${${dir}_tarball_directory}.tar.gz"
    )
endforeach()

