package platform::ClangWindows;

# Platform naming for the mingw-clang-msvc64 Configure target: the mingw
# layout (DLLs in bin, import/static libraries in lib), with the file names of
# the nmake flow so consumers see the same package either way:
# libcrypto-3-x64.dll and libcrypto.lib.

use strict;
use warnings;
use Carp;

use vars qw(@ISA);

require platform::mingw;
@ISA = qw(platform::mingw);

# Assume someone set @INC right before loading this module
use configdata;

sub libext              { '.lib' }
sub shlibextimport      { '.lib' }

sub staticname {
    my $in_libname = platform::BASE->staticname($_[1]);
    return $in_libname
        if $unified_info{attributes}->{libraries}->{$_[1]}->{noinst};

    # Avoid clashing with the import library in shared builds.
    return $in_libname . ($disabled{shared} ? '' : '_static');
}

# The unix Makefile links a dependency on libcrypto or libssl (named without
# an extension) as -L<dir> -l<name without "lib">, which the clang driver
# turns into crypto.lib for windows-msvc. Have those link rules take the
# library by file name instead - the import library in shared builds, the
# archive in static ones; isstaticlib and convertext are only asked this by
# them.
sub __is_library_dependency {
    my $lib = $_[1];
    return !$_[0]->SUPER::isstaticlib($lib)
        && grep { $_ eq $lib } @{$unified_info{libraries}};
}

sub isstaticlib {
    return $_[0]->SUPER::isstaticlib($_[1]) || $_[0]->__is_library_dependency($_[1]);
}

sub convertext {
    if ($_[0]->__is_library_dependency($_[1])) {
        return $disabled{shared}
            ? $_[0]->staticlib($_[1])
            : $_[0]->sharedlib_import($_[1]);
    }
    return $_[0]->SUPER::convertext($_[1]);
}

sub sharedname {
    return platform::BASE::__concat(platform::BASE->sharedname($_[1]),
                                    "-",
                                    $_[0]->shlib_version_as_filename(),
                                    "-x64");
}

1;
