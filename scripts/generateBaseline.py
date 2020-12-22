import os
import json
import subprocess
import sys

SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))


def generate_baseline(ports_path, output_filepath):
    port_names = [item for item in os.listdir(
        ports_path) if os.path.isdir(os.path.join(ports_path, item))]
    port_names.sort()

    total = len(port_names)
    baseline_versions = {}
    for counter, port_name in enumerate(port_names):
        vcpkg_exe = os.path.join(SCRIPT_DIRECTORY, '../vcpkg')
        print(f'[{counter + 1}/{total}] Getting package info for {port_name}')
        output = subprocess.run(
            [vcpkg_exe, 'x-package-info', '--x-json', port_name],
            capture_output=True,
            encoding='utf-8')

        if output.returncode == 0:
            package_info = json.loads(output.stdout)
            port_info = package_info['results'][port_name]

            version = {}
            for scheme in ['version-string', 'version-semver', 'version-date', 'version']:
                if scheme in port_info:
                    version[scheme] = package_info['results'][port_name][scheme]
                    break
            version['port-version'] = 0
            if 'port-version' in port_info:
                version['port-version'] = port_info['port-version']
            baseline_versions[port_name] = version
        else:
            print(f'x-package-info --x-json {port_name} failed: ', output.stdout.strip(), file=sys.stderr)

    output = {}
    output['default'] = baseline_versions

    with open(output_filepath, 'r') as output_file:
        json.dump(baseline_versions, output_file)
    sys.exit(0)


if __name__ == '__main__':
    generate_baseline(
        ports_path=f'{SCRIPT_DIRECTORY}/../ports', output_filepath='baseline.json')
