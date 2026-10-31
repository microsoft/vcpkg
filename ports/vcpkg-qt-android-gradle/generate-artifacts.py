#!/usr/bin/env python3
"""Generates gradle-artifacts.cmake for the vcpkg-qt-android-gradle port.

1. Runs Qt's Android JAR Gradle builds online with an empty GRADLE_USER_HOME,
   exactly like qt_internal_add_jar() does, for the Debug and Release variants.
2. Collects every artifact Gradle downloaded into its cache, finds the repository
   that serves it and records its SHA512. Host specific artifacts (aapt2) are
   added for linux, osx and windows.
3. Rebuilds a local Maven repository plus GRADLE_USER_HOME the same way the port
   does and reruns Qt's offline cache check and the builds with network access blocked.
4. Records the qtbase files the result depends on, so qtbase can detect outdated artifacts.

Requirements: Python 3.8+, JDK 17+ (JAVA_HOME or java on PATH), CMake, an Android SDK
with build-tools and a platform installed, network access. generate-in-docker.sh
provides all of these.

qtbase reports when this has to be rerun, both in QT_UPDATE_VERSION mode and when
building for Android. Manual use:

  python3 generate-artifacts.py --qtbase-source qtbase-everywhere-src-6.12.0 --android-sdk /android-sdk
"""

import argparse
import concurrent.futures
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

# Order matters: an artifact is attributed to the first repository serving identical content.
REPOSITORIES = [
    ("google", "https://dl.google.com/dl/android/maven2"),
    ("central", "https://repo.maven.apache.org/maven2"),
    ("plugins", "https://plugins.gradle.org/m2"),
]
HOST_SYSTEMS = ("linux", "osx", "windows")
HOST_SPECIFIC_RE = re.compile(r"^(?P<prefix>.+)-(?P<os>linux|osx|windows)\.jar$")
VARIANTS = ("Debug", "Release")
USER_AGENT = "vcpkg-qt-android-gradle-generator"


def log(message):
    print(message, flush=True)


def fail(message):
    sys.exit(f"error: {message}")


def file_hash(path, algorithm):
    digest = hashlib.new(algorithm)
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fetch(url, retries=3):
    """Returns the content of url, or None if the server answers 404."""
    for attempt in range(retries):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=120) as response:
                return response.read()
        except urllib.error.HTTPError as e:
            if e.code in (403, 404):
                return None
            error = e
        except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
            error = e
        time.sleep(2 ** attempt)
    fail(f"failed to fetch {url}: {error}")


def gradle_wrapper_hash(url):
    """Directory name the Gradle wrapper uses for a distribution: base36 of the MD5 of the URL."""
    value = int(hashlib.md5(url.encode("utf-8")).hexdigest(), 16)
    digits = "0123456789abcdefghijklmnopqrstuvwxyz"
    result = ""
    while value:
        value, remainder = divmod(value, 36)
        result = digits[remainder] + result
    return result or "0"


def read_wrapper_url(qtbase):
    properties = qtbase / "src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties"
    for line in properties.read_text(encoding="utf-8").splitlines():
        if line.startswith("distributionUrl="):
            return line[len("distributionUrl="):].strip().replace("\\:", ":").replace("\\=", "=")
    fail(f"no distributionUrl in {properties}")


def discover_projects(qtbase):
    """Gradle JAR projects as detected by qt_internal_add_jar(), without app templates."""
    projects = []
    for build_gradle in sorted((qtbase / "src").rglob("build.gradle")):
        project = build_gradle.parent
        if "templates" in project.relative_to(qtbase).parts:
            continue
        if (project / "settings.gradle").is_file() and (project / "gradle/libs.versions.toml").is_file():
            projects.append(project)
    return projects


def input_files(qtbase, projects):
    """qtbase files which determine the distribution and artifacts, see vcpkg-qt-android-gradle-inputs.cmake."""
    files = [
        "src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties",
        "cmake/android/qt-android-init.gradle",
    ]
    for project in projects:
        try:
            relative = project.relative_to(qtbase).as_posix()
        except ValueError:
            continue
        for name in ("build.gradle", "settings.gradle", "gradle.properties", "gradle/libs.versions.toml"):
            if (project / name).is_file():
                files.append(f"{relative}/{name}")
    return sorted(f"{path}|{file_hash(qtbase / path, 'sha512')}" for path in files if (qtbase / path).is_file())


def root_project_name(project):
    match = re.search(r"rootProject\.name\s*=\s*['\"]([^'\"]+)['\"]",
                      (project / "settings.gradle").read_text(encoding="utf-8"))
    if not match:
        fail(f"no rootProject.name in {project / 'settings.gradle'}")
    return match.group(1)


def highest_version(directory, prefix=""):
    def key(name):
        return [int(part) if part.isdigit() else 0 for part in re.split(r"[.-]", name[len(prefix):])]
    names = [p.name for p in directory.iterdir() if p.is_dir() and p.name.startswith(prefix)] \
        if directory.is_dir() else []
    if not names:
        fail(f"nothing installed in {directory}")
    return max(names, key=key)


def write_gradle_home(gradle_home, repository_dir=None, block_network=False):
    gradle_home.mkdir(parents=True, exist_ok=True)
    properties = (SCRIPT_DIR / "gradle.properties").read_text(encoding="utf-8")
    if block_network:
        properties += "".join(f"systemProp.{scheme}.proxyHost=127.0.0.1\nsystemProp.{scheme}.proxyPort=9\n"
                              for scheme in ("http", "https"))
    (gradle_home / "gradle.properties").write_text(properties, encoding="utf-8")
    if repository_dir is not None:
        init_script = (SCRIPT_DIR / "vcpkg-offline-repository.gradle.in").read_text(encoding="utf-8")
        init_script = init_script.replace("@QT_ANDROID_GRADLE_REPOSITORY_DIR@", repository_dir.as_posix())
        (gradle_home / "init.d").mkdir(exist_ok=True)
        (gradle_home / "init.d/vcpkg-offline-repository.gradle").write_text(init_script, encoding="utf-8")


def gradle_env(args, gradle_home, block_network):
    env = dict(os.environ)
    env["GRADLE_USER_HOME"] = str(gradle_home)
    # Same as vcpkg_qt_android_gradle_setup(): there may be no usable ~/.android.
    env["ANDROID_USER_HOME"] = str(gradle_home / "android-user-home")
    (gradle_home / "android-user-home").mkdir(parents=True, exist_ok=True)
    env["ANDROID_SDK_ROOT"] = str(args.android_sdk)
    env["ANDROID_HOME"] = str(args.android_sdk)
    if block_network:
        blocked = " ".join(f"-D{scheme}.proxyHost=127.0.0.1 -D{scheme}.proxyPort=9" for scheme in ("http", "https"))
        env["JAVA_OPTS"] = f"{env.get('JAVA_OPTS', '')} {blocked}".strip()
        env["GRADLE_OPTS"] = f"{env.get('GRADLE_OPTS', '')} {blocked}".strip()
    return env


def run_qt_verify(args, project, variant, gradle_home):
    """The offline check Qt runs at configure time, see _qt_internal_verify_gradle_offline_cache()."""
    command = [
        args.cmake,
        "-DACTION_RESOLVE_GRADLE=ON",
        f"-DQT_ROOT_DIR={args.qtbase_source.as_posix()}",
        f"-DGRADLE_PROJECT_DIR={project.as_posix()}",
        f"-DGRADLE_BUILD_VARIANT={variant}",
        "-DONLY_VERIFY_GRADLE_CACHE=ON",
        f"-DQT_ANDROID_SDK_BUILD_TOOLS_REVISION={args.build_tools}",
        "-P", str(args.qtbase_source / "cmake/QtSetupAndroid.cmake"),
    ]
    log(f"-- Qt offline cache check: {project} [{variant}]")
    result = subprocess.run(command, env=gradle_env(args, gradle_home, block_network=True))
    if result.returncode != 0:
        fail(f"Qt's offline Gradle cache check of {project} [{variant}] failed with exit code {result.returncode}")


def run_gradle(args, project, variant, gradle_home, build_root, offline, block_network=False):
    qtbase = args.qtbase_source
    if os.name == "nt":
        gradlew = [str(qtbase / "src/3rdparty/gradle/gradlew.bat")]
    else:
        gradlew = ["sh", str(qtbase / "src/3rdparty/gradle/gradlew")]
    init_script = qtbase / "cmake/android/qt-android-init.gradle"
    if os.name == "nt":
        # Same as QtSetupAndroid.cmake: relative path avoids POSIX-style misinterpretation by Gradle.
        try:
            init_script = Path(os.path.relpath(init_script, project))
        except ValueError:
            pass
    name = root_project_name(project)
    build_dir = build_root / f"{name}-{variant}"
    command = gradlew + [
        "--init-script", str(init_script),
        f"-PbuildDir={build_dir.as_posix()}/build",
        f"-PjarOutputDir={build_dir.as_posix()}/jar",
        f"-PbuildVariant={variant}",
        f"-PjavacSource={args.javac_version}",
        f"-PjavacTarget={args.javac_version}",
        f"-PcompileSdk={args.compile_sdk}",
        f"-PminSdk={args.min_sdk}",
        f"-PbuildToolsVersion={args.build_tools}",
        "-PisQtCMakeBuild=true",
        "--project-cache-dir", str(build_dir / ".gradle"),
        "--no-configuration-cache",
        "--no-daemon",
    ]
    if offline:
        command.append("--offline")
    command += [f"{name}Jar", "resolveDependencies"]

    mode = "offline" if offline else "online"
    log(f"-- Gradle {mode}: {project} [{variant}]")
    result = subprocess.run(command, cwd=project, env=gradle_env(args, gradle_home, block_network))
    if result.returncode != 0:
        fail(f"Gradle {mode} build of {project} [{variant}] failed with exit code {result.returncode}")
    jar = build_dir / "jar" / f"{name}.jar"
    if not jar.is_file():
        fail(f"Gradle build of {project} [{variant}] did not produce {jar}")


def collect_cache(gradle_home):
    """Maps maven path -> cached file for everything in Gradle's module cache."""
    files_root = gradle_home / "caches/modules-2/files-2.1"
    artifacts = {}
    for file in sorted(files_root.glob("*/*/*/*/*")):
        if not file.is_file():
            continue
        version_dir = file.parent.parent
        module_dir = version_dir.parent
        group_dir = module_dir.parent
        path = f"{group_dir.name.replace('.', '/')}/{module_dir.name}/{version_dir.name}/{file.name}"
        if path in artifacts and file_hash(artifacts[path], "sha1") != file_hash(file, "sha1"):
            fail(f"different files for {path} in the Gradle cache")
        artifacts[path] = file
    if not artifacts:
        fail(f"no artifacts in {files_root}")
    return artifacts


def find_repository(path, file):
    sha1 = file_hash(file, "sha1")
    for name, base in REPOSITORIES:
        url = f"{base}/{path}"
        remote_sha1 = fetch(url + ".sha1")
        if remote_sha1 is not None:
            if remote_sha1.decode("ascii", "replace").split()[0].lower() == sha1:
                return name
            continue
        content = fetch(url)
        if content is not None and hashlib.sha1(content).hexdigest() == sha1:
            return name
    fail(f"no repository serves {path} with SHA1 {sha1}")


def host_specific_siblings(path, repository, work_dir):
    """Downloads the artifacts for the other host systems, e.g. aapt2-<version>-windows.jar."""
    directory, filename = path.rsplit("/", 1)
    match = HOST_SPECIFIC_RE.match(filename)
    siblings = {}
    for host in HOST_SYSTEMS:
        if host == match.group("os"):
            continue
        sibling_path = f"{directory}/{match.group('prefix')}-{host}.jar"
        content = fetch(f"{dict(REPOSITORIES)[repository]}/{sibling_path}")
        if content is None:
            log(f"warning: {sibling_path} does not exist in {repository}, skipping it")
            continue
        target = work_dir / "host-specific" / sibling_path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)
        siblings[sibling_path] = (host, target)
    return siblings


def write_output(output, args, distribution, entries, inputs):
    url, name, wrapper_hash, sha512 = distribution
    lines = [
        f"# Generated by generate-artifacts.py from {args.qtbase_source.name}. Do not edit.",
        f"# Android build-tools {args.build_tools}, compileSdk {args.compile_sdk}, minSdk {args.min_sdk}.",
        f'set(QT_ANDROID_GRADLE_DISTRIBUTION_URL "{url}")',
        f'set(QT_ANDROID_GRADLE_DISTRIBUTION_NAME "{name}")',
        f'set(QT_ANDROID_GRADLE_DISTRIBUTION_HASH "{wrapper_hash}")',
        f'set(QT_ANDROID_GRADLE_DISTRIBUTION_SHA512 "{sha512}")',
    ]
    lines += [f'set(QT_ANDROID_GRADLE_REPOSITORY_{repo} "{base}")' for repo, base in REPOSITORIES]
    lines.append("# qtbase files the artifacts were generated from: <path>|<sha512>")
    lines.append("set(QT_ANDROID_GRADLE_INPUTS")
    lines += [f'    "{entry}"' for entry in inputs]
    lines.append(")")
    lines.append("set(QT_ANDROID_GRADLE_ARTIFACTS")
    for path in sorted(entries):
        repository, host, _, file_sha512 = entries[path]
        lines.append(f'    "{repository}|{host}|{path}|{file_sha512}"')
    lines.append(")")
    output.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--qtbase-source", type=Path, required=True,
                        help="extracted qtbase sources of the Qt version the port is for")
    parser.add_argument("--project", type=Path, action="append", default=[],
                        help="Gradle JAR project to resolve (repeatable, default: all JAR projects of qtbase)")
    parser.add_argument("--android-sdk", type=Path,
                        default=os.environ.get("ANDROID_SDK_ROOT") or os.environ.get("ANDROID_HOME"),
                        help="Android SDK root (default: ANDROID_SDK_ROOT or ANDROID_HOME)")
    parser.add_argument("--build-tools", help="Android build-tools revision (default: highest installed)")
    parser.add_argument("--compile-sdk", help="Android compileSdk (default: highest installed platform)")
    parser.add_argument("--min-sdk", default="28", help="Android minSdk (default: %(default)s)")
    parser.add_argument("--javac-version", default="17", help="javac source and target (default: %(default)s)")
    parser.add_argument("--output", type=Path, default=SCRIPT_DIR / "gradle-artifacts.cmake",
                        help="output file (default: %(default)s)")
    parser.add_argument("--work-dir", type=Path, help="working directory (default: a new temporary directory)")
    parser.add_argument("--keep-work-dir", action="store_true", help="do not delete the working directory")
    parser.add_argument("--skip-self-check", action="store_true", help="skip the offline verification")
    parser.add_argument("--jobs", type=int, default=16, help="parallel repository lookups (default: %(default)s)")
    parser.add_argument("--cmake", default=shutil.which("cmake"), help="CMake for Qt's offline cache check")
    args = parser.parse_args()

    args.qtbase_source = args.qtbase_source.resolve()
    if not (args.qtbase_source / "cmake/QtSetupAndroid.cmake").is_file():
        fail(f"{args.qtbase_source} is not a qtbase source tree with Gradle support")
    if not args.android_sdk or not Path(args.android_sdk).is_dir():
        fail("pass --android-sdk or set ANDROID_SDK_ROOT")
    args.android_sdk = Path(args.android_sdk).resolve()
    if not os.environ.get("JAVA_HOME") and not shutil.which("java"):
        fail("no JDK found: set JAVA_HOME or put java on PATH")
    if not args.skip_self_check and not args.cmake:
        fail("no CMake found: pass --cmake or put cmake on PATH")
    args.build_tools = args.build_tools or highest_version(args.android_sdk / "build-tools")
    args.compile_sdk = args.compile_sdk or highest_version(args.android_sdk / "platforms", "android-")[len("android-"):]
    projects = [p.resolve() for p in args.project] or discover_projects(args.qtbase_source)
    if not projects:
        fail("no Gradle JAR projects found")
    log("-- Projects:\n" + "\n".join(f"     {p}" for p in projects))
    log(f"-- build-tools {args.build_tools}, compileSdk {args.compile_sdk}, minSdk {args.min_sdk}")

    work_dir = (args.work_dir or Path(tempfile.mkdtemp(prefix="qt-android-gradle-"))).resolve()
    if work_dir.exists() and any(work_dir.iterdir()):
        fail(f"working directory {work_dir} is not empty")
    work_dir.mkdir(parents=True, exist_ok=True)
    log(f"-- Working directory: {work_dir}")
    try:
        # 1. Online builds with an empty Gradle user home.
        online_home = work_dir / "gradle-home-online"
        write_gradle_home(online_home)
        for project in projects:
            for variant in VARIANTS:
                run_gradle(args, project, variant, online_home, work_dir / "build-online", offline=False)

        # 2. Gradle distribution and artifacts.
        url = read_wrapper_url(args.qtbase_source)
        name = url.rsplit("/", 1)[-1]
        if not name.endswith(".zip"):
            fail(f"unexpected Gradle distribution URL {url}")
        name = name[:-len(".zip")]
        wrapper_hash = gradle_wrapper_hash(url)
        if not (online_home / "wrapper/dists" / name / wrapper_hash / f"{name}.zip.ok").is_file():
            fail(f"Gradle wrapper did not use wrapper/dists/{name}/{wrapper_hash}; "
                 "is the wrapper hash computation still valid?")
        # The wrapper deletes the zip after unpacking it.
        log(f"-- Downloading {url}")
        content = fetch(url)
        if content is None:
            fail(f"failed to download {url}")
        zip_file = work_dir / f"{name}.zip"
        zip_file.write_bytes(content)
        distribution = (url, name, wrapper_hash, file_hash(zip_file, "sha512"))

        cached = collect_cache(online_home)
        log(f"-- Looking up the repositories of {len(cached)} artifacts")
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            repositories = dict(zip(cached, pool.map(lambda item: find_repository(*item), cached.items())))

        entries = {}  # path -> (repository, host, file, sha512)
        for path, file in cached.items():
            repository = repositories[path]
            match = HOST_SPECIFIC_RE.match(path.rsplit("/", 1)[1])
            host = match.group("os") if match else "any"
            entries[path] = (repository, host, file, file_hash(file, "sha512"))
            if match:
                for sibling_path, (sibling_host, sibling_file) in \
                        host_specific_siblings(path, repository, work_dir).items():
                    entries[sibling_path] = (repository, sibling_host, sibling_file,
                                             file_hash(sibling_file, "sha512"))

        # 3. Offline verification with the layout used by the port.
        if not args.skip_self_check:
            repository_dir = work_dir / "m2"
            for path, (_, _, file, _) in entries.items():
                target = repository_dir / path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(file, target)
            offline_home = work_dir / "gradle-home-offline"
            write_gradle_home(offline_home, repository_dir, block_network=True)
            dist_dir = offline_home / "wrapper/dists" / name / wrapper_hash
            dist_dir.mkdir(parents=True)
            shutil.copyfile(zip_file, dist_dir / zip_file.name)
            for project in projects:
                for variant in VARIANTS:
                    run_qt_verify(args, project, variant, offline_home)
                    run_gradle(args, project, variant, offline_home, work_dir / "build-offline",
                               offline=True, block_network=True)
            log("-- Offline verification passed")

        write_output(args.output, args, distribution, entries, input_files(args.qtbase_source, projects))
        size = sum(e[2].stat().st_size for e in entries.values()) + zip_file.stat().st_size
        log(f"-- Wrote {len(entries)} artifacts ({size / (1 << 20):.0f} MiB incl. the Gradle distribution) "
            f"to {args.output}")
    finally:
        if args.keep_work_dir:
            log(f"-- Kept working directory {work_dir}")
        else:
            shutil.rmtree(work_dir, ignore_errors=True)


if __name__ == "__main__":
    main()
