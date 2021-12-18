import os
import sys
import json
import time

from pathlib import Path


SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
PORTS_DIRECTORY = os.path.join(SCRIPT_DIRECTORY, '../ports')
VERSIONS_DB_DIRECTORY = os.path.join(SCRIPT_DIRECTORY, '../versions')


def get_version_tag(version):
    if 'version' in version:
        return version['version']
    elif 'version-date' in version:
        return version['version-date']
    elif 'version-semver' in version:
        return version['version-semver']
    elif 'version-string' in version:
        return version['version-string']
    sys.exit(1)


def get_version_port_version(version):
    if 'port-version' in version:
        return version['port-version']
    return 0


def generate_baseline():
    start_time = time.time()

    # Assume each directory in ${VCPKG_ROOT}/ports is a different port
    port_names = [item for item in os.listdir(
        PORTS_DIRECTORY) if os.path.isdir(os.path.join(PORTS_DIRECTORY, item))]
    port_names.sort()

    baseline_entries = {}
    total_count = len(port_names)
    for i, port_name in enumerate(port_names, 1):
        port_file_path = os.path.join(
            VERSIONS_DB_DIRECTORY, f'{port_name[0]}-', f'{port_name}.json')

        if not os.path.exists(port_file_path):
            print(
                f'Error: No version file for {port_name}.\n', file=sys.stderr)
            continue
        sys.stderr.write(
            f'\rProcessed {i}/{total_count} ({i/total_count:.2%})')
        with open(port_file_path, 'r') as db_file:
            try:
                versions_object = json.load(db_file)
                if versions_object['versions']:
                    last_version = versions_object['versions'][0]
                    baseline_entries[port_name] = {
                        'baseline': get_version_tag(last_version),
                        'port-version': get_version_port_version(last_version)
                    }
            except json.JSONDecodeError as e:
                print(f'Error: Decoding {port_file_path}\n{e}\n')
    baseline_object = {}
    baseline_object['default'] = baseline_entries

    os.makedirs(VERSIONS_DB_DIRECTORY, exist_ok=True)
    baseline_path = os.path.join(VERSIONS_DB_DIRECTORY, 'baseline.json')
    with open(baseline_path, 'w') as baseline_file:
        json.dump(baseline_object, baseline_file)

    elapsed_time = time.time() - start_time
    print(f'\nElapsed time: {elapsed_time:.2f} seconds')


def main():
    if not os.path.exists(VERSIONS_DB_DIRECTORY):
        print(f'Version DB files must exist before generating a baseline.\nRun: `python generatePortVersionsDB`\n')
    generate_baseline()


if __name__ == "__main__":
    main()
