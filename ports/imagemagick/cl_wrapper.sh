#!/bin/sh
# cl wrapper (cc_basename=cl -> libtool MSVC mode)
# Translates:
#   -o file      -> -Fofile (object) or -Fefile (executable)
#   -lfoo        -> foo.lib (with smart resolution)
#   -Lpath       -> -libpath:path
#   -Wl,f1,f2    -> f1 f2
# All linker flags (-l, -L, -Wl) are accumulated and placed after -link.
#
# The -o translation allows autotools to skip config/compile, which has
# incomplete library resolution (misses lib-prefixed .lib, debug suffixes,
# and versioned names).  With this, am_cv_prog_cc_c_o=yes can be set.
#
# For -lfoo, the wrapper searches known -L directories for the actual library
# file (foo.lib, libfoo.a, libfoo.lib, foo.a) to handle non-MSVC naming
# (e.g. Meson produces libfoo.a on Windows even with MSVC/clang-cl).
# Also tries MSVC debug-suffix (food.lib) and versioned names (foo.1.2.lib).
# Falls back to foo.lib if no file is found.
#
# $REAL_CC must be set to the actual compiler (cl.exe or clang-cl path).
# MUST use POSIX sh — MSYS2 /bin/sh is NOT bash (no arrays, no +=).
# resolve_lib NAME: search lib_dirs for the actual library file matching NAME.
# Prints the resolved filename (e.g. lcms2.lib or liblcms2.a).
# Falls back to NAME.lib if not found in any directory.
resolve_lib() {
    _name="$1"
    for _dir in $lib_dirs; do
        # Exact-name candidates (most common)
        for _candidate in "${_name}.lib" "lib${_name}.a" "lib${_name}.lib" "${_name}.a"; do
            if [ -f "${_dir}/${_candidate}" ]; then
                echo "$_candidate"
                return
            fi
        done
        # MSVC debug-suffix candidates (e.g. bz2d.lib for -lbz2)
        for _candidate in "${_name}d.lib" "lib${_name}d.lib"; do
            if [ -f "${_dir}/${_candidate}" ]; then
                echo "$_candidate"
                return
            fi
        done
        # Versioned candidates via glob (e.g. openjph.0.27.lib for -lopenjph).
        # If more than one file matches the glob the result is ambiguous,
        # so we skip and fall back to the default NAME.lib.
        set -- "${_dir}/${_name}".*.lib
        if [ $# -eq 1 ] && [ -f "$1" ]; then
            echo "${1##*/}"
            return
        fi
    done
    echo "${_name}.lib"
}

tmpf=$(mktemp)
trap 'rm -f "$tmpf"' EXIT
link_flags=""
lib_dirs=""
had_link=0
eat_next=""
for arg; do
    # If previous arg was -o, this arg is the output filename
    if [ -n "$eat_next" ]; then
        case "$arg" in
            *.o|*.obj|*.lo)  echo "-Fo$arg" >> "$tmpf" ;;
            *)               echo "-Fe$arg" >> "$tmpf" ;;
        esac
        eat_next=""
        continue
    fi
    case "$arg" in
        -o)
            eat_next=1
            ;;
        -link|-LINK|-link.exe)
            had_link=1
            echo "-link" >> "$tmpf"
            # Flush accumulated linker flags right after -link
            if [ -n "$link_flags" ]; then
                for lf in $link_flags; do echo "$lf" >> "$tmpf"; done
                link_flags=""
            fi
            ;;
        -LIBPATH:*|-libpath:*)
            # MSVC-native libpath — pass through unchanged.
            # Must be matched BEFORE -l* / -L* because MSYS2 sh case-folds paths: -LIBPATH: would match -L*.
            echo "$arg" >> "$tmpf"
            ;;
        -Wl,*)
            # GCC-style linker passthrough: -Wl,flag1,flag2 -> flag1 flag2
            # cl.exe does not understand -Wl, but we can translate it.
            rest="${arg#-Wl,}"
            old_IFS="$IFS"; IFS=','
            for wl_flag in $rest; do
                if [ "$had_link" = "1" ]; then
                    echo "$wl_flag" >> "$tmpf"
                else
                    link_flags="$link_flags $wl_flag"
                fi
            done
            IFS="$old_IFS"
            ;;
        -l*)
            lib=$(resolve_lib "${arg#-l}")
            if [ "$had_link" = "1" ]; then
                echo "$lib" >> "$tmpf"
            else
                link_flags="$link_flags $lib"
            fi
            ;;
        -L*)
            dir="${arg#-L}"
            lib_dirs="$lib_dirs $dir"
            lp="-libpath:$dir"
            if [ "$had_link" = "1" ]; then
                echo "$lp" >> "$tmpf"
            else
                link_flags="$link_flags $lp"
            fi
            ;;
        *)  echo "$arg" >> "$tmpf" ;;
    esac
done
# Append remaining linker flags after -link
if [ -n "$link_flags" ]; then
    echo "-link" >> "$tmpf"
    for lf in $link_flags; do echo "$lf" >> "$tmpf"; done
fi
# Read back args, one per line, and exec the real compiler
set --
while IFS= read -r line; do
    set -- "$@" "$line"
done < "$tmpf"
exec "$REAL_CC" "$@"
