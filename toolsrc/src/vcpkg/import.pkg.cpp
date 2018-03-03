#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/statusparagraph.h>
#include <vcpkg/import.h>
#include <vcpkg/import.pkg.h>

namespace vcpkg::Import::Pkg
{
    void do_import(const VcpkgPaths& paths, const Options& opts)
    {
        auto& fs = paths.get_filesystem();
        const fs::path vcexport_file_path = fs::path(opts.maybe_vcexport_file_path.value_or_exit(VCPKG_LINE_INFO));

        // FIXME: implement me.
        //
        // extract exported files
        // copy installed/x64-windows installed/x86-windows into proper directory
        //
        // for each  *.info file in installed/vcpkg/info
        //      file has a filiname <libname>_<version>_<triplet>.info
        //         for example, hoge_1.0_x86-windows.info
        //      detect library name and store it to target.name
        //      detect version and store it to target.version
        //      detect triplet and store it to target.triplet
        //
        //      - CONTROL file
        //        read ports/<libname>/CONTROL
        //        modify version string to be same as exported one.
        //        write into packages/<libname>_<triplet>/CONTROL
        //      - BUILD_INFO file
        //        We just put hardcoded one.
        //        for shared
        //           CRTLinkage: daynamic
        //           LibraryLinkage: dynamic
        //        for static
        //           CRTLinkage: static
        //           LibraryLinkage: static
        //      - Retrieve binary files based on .info contents
        //        read *.info line
        //           example: hoge_x86-windows/bin/hoge.dll
        //        copy files into packages/<libname>_<triplet>/
        //          for exampke,  packages/hoge_x86-windows/bin/hoge.dll
        //
        //  endforeach
    }
}