function(prepare_for_build CTSTRAFFIC_SOURCE_DIR)

    message("-- Modifying hardcoded 'NuGet' directives in .vcxproj files")
    file(GLOB_RECURSE PROJ_FILES "${CTSTRAFFIC_SOURCE_DIR}/*.vcxproj")
	
    foreach(PROJ_FILE ${PROJ_FILES})
        file(READ ${PROJ_FILE} PROJ_FILE_CONTENT)
        STRING(REGEX
            REPLACE
                "<Target Name=\"EnsureNuGetPackageBuildImports\" BeforeTargets=\"PrepareForBuild\">"
                "<Target Name=\"EnsureNuGetPackageBuildImports\" BeforeTargets=\"PrepareForBuild\" Condition=\"'$(UseVcpkg)' != 'yes'\">"
            PROJ_FILE_CONTENT
            "${PROJ_FILE_CONTENT}"
        )

        file(WRITE ${PROJ_FILE} "${PROJ_FILE_CONTENT}")
    endforeach()

endfunction()
