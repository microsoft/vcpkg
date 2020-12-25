import os
import os.path
import sys
import subprocess
import json
import time
import shutil

from subprocess import CalledProcessError
from json.decoder import JSONDecodeError
from pathlib import Path


SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))


def get_current_git_ref():
    output = subprocess.run(['git', '-C', SCRIPT_DIRECTORY, 'rev-parse', '--verify', 'HEAD'],
                            capture_output=True,
                            encoding='utf-8')
    if output.returncode == 0:
        return output.stdout.strip()
    print(f"Failed to get git ref:", output.stderr.strip(), file=sys.stderr)
    return None


def generate_port_versions_db(ports_path, db_path, revision):
    start_time = time.time()

    # Assume each directory in ${VCPKG_ROOT}/ports is a different port
    port_names = [item for item in os.listdir(
        ports_path) if os.path.isdir(os.path.join(ports_path, item))]
    port_names.sort()
    total_count = len(port_names)

    # Dictionary to collect the latest version of each port as baseline
    baseline_objects = {}
    baseline_objects['default'] = {}

    for counter, port_name in enumerate(port_names):
        containing_dir = os.path.join(db_path, f'{port_name[0]}-')
        os.makedirs(containing_dir, exist_ok=True)

        output_filepath = os.path.join(containing_dir, f'{port_name}.json')
        if not os.path.exists(output_filepath):
            output = subprocess.run(
                [os.path.join(SCRIPT_DIRECTORY, '../vcpkg'),
                 'x-history', port_name, '--x-json'],
                capture_output=True, encoding='utf-8')

            if output.returncode == 0:
                try:
                    versions_object = json.loads(output.stdout)

                    # Put latest version in baseline dictionary
                    latest_version = versions_object["versions"][0]
                    baseline_objects['default'][port_name] = {
                        "version-string": latest_version["version-string"],
                        "port-version": latest_version["port-version"]
                    }
                    with open(output_filepath, 'w') as output_file:
                        json.dump(versions_object, output_file)
                except JSONDecodeError:
                    print(
                        f'Malformed JSON from vcpkg x-history {port_name}: ', output.stdout.strip(), file=sys.stderr)
            else:
                print(f'x-history {port_name} failed: ',
                      output.stdout.strip(), file=sys.stderr)

        # This should be replaced by a progress bar
        if counter > 0 and counter % 100 == 0:
            elapsed_time = time.time() - start_time
            print(
                f'Processed {counter} out of {total_count}. Elapsed time: {elapsed_time:.2f} seconds')

    # Generate baseline.json
    baseline_file_path = os.path.join(db_path, 'baseline.json')
    with open(baseline_file_path, 'w') as baseline_output_file:
        json.dump(baseline_objects, baseline_output_file)

    # Generate timestamp
    rev_file = os.path.join(db_path, revision)
    Path(rev_file).touch()

    elapsed_time = time.time() - start_time
    print(
        f'Processed {total_count} total ports. Elapsed time: {elapsed_time:.2f} seconds')


def main(ports_path, db_path):
    revision = get_current_git_ref()
    if not revision:
        print('Couldn\'t fetch current Git revision', file=sys.stderr)
        sys.exit(1)

    rev_file = os.path.join(db_path, revision)
    if os.path.exists(rev_file):
        print(f'Database files already exist for commit {revision}')
        sys.exit(0)

    if (os.path.exists(db_path)):
        try:
            shutil.rmtree(db_path)
        except OSError as e:
            print(f'Could not delete folder: {db_path}.\nError: {e.strerror}')

    generate_port_versions_db(ports_path=ports_path,
                              db_path=db_path,
                              revision=revision)


if __name__ == "__main__":
    main(ports_path=os.path.join(SCRIPT_DIRECTORY, '../ports'),
         db_path=os.path.join(SCRIPT_DIRECTORY, '../port_versions'))
