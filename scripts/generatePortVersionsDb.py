import os
import sys
import subprocess
import json
import time
import shutil

import multiprocessing

from pathlib import Path


MAX_PROCESSES = multiprocessing.cpu_count()
SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
PORTS_DIRECTORY = os.path.join(SCRIPT_DIRECTORY, '../ports')
VERSIONS_DB_DIRECTORY = os.path.join(SCRIPT_DIRECTORY, '../versions')


def get_current_git_ref():
    output = subprocess.run(['git', '-C', SCRIPT_DIRECTORY, 'rev-parse', '--verify', 'HEAD'],
                            capture_output=True,
                            encoding='utf-8')
    if output.returncode == 0:
        return output.stdout.strip()
    print(f"Failed to get git ref:", output.stderr.strip(), file=sys.stderr)
    return None


def generate_versions_file(port_name):
    containing_dir = os.path.join(VERSIONS_DB_DIRECTORY, f'{port_name[0]}-')
    os.makedirs(containing_dir, exist_ok=True)

    output_file_path = os.path.join(containing_dir, f'{port_name}.json')
    if not os.path.exists(output_file_path):
        env = os.environ.copy()
        env['GIT_OPTIONAL_LOCKS'] = '0'
        output = subprocess.run(
            [os.path.join(SCRIPT_DIRECTORY, '../vcpkg'),
             'x-history', port_name, '--x-json', f'--output={output_file_path}'],
            capture_output=True, encoding='utf-8', env=env)
        if output.returncode != 0:
            print(f'x-history {port_name} failed: ',
                  output.stdout.strip(), file=sys.stderr)


def generate_versions_db(revision):
    start_time = time.time()

    # Assume each directory in ${VCPKG_ROOT}/ports is a different port
    port_names = [item for item in os.listdir(
        PORTS_DIRECTORY) if os.path.isdir(os.path.join(PORTS_DIRECTORY, item))]
    total_count = len(port_names)

    concurrency = MAX_PROCESSES / 2
    print(f'Running {concurrency:.0f} parallel processes')
    process_pool = multiprocessing.Pool(MAX_PROCESSES)
    for i, _ in enumerate(process_pool.imap_unordered(generate_versions_file, port_names), 1):
        sys.stderr.write(
            f'\rProcessed: {i}/{total_count} ({(i / total_count):.2%})')
    process_pool.close()
    process_pool.join()

    # Generate timestamp
    rev_file = os.path.join(VERSIONS_DB_DIRECTORY, revision)
    Path(rev_file).touch()

    elapsed_time = time.time() - start_time
    print(
        f'\nElapsed time: {elapsed_time:.2f} seconds')


def main():
    revision = get_current_git_ref()
    if not revision:
        print('Couldn\'t fetch current Git revision', file=sys.stderr)
        sys.exit(1)

    rev_file = os.path.join(VERSIONS_DB_DIRECTORY, revision)
    if os.path.exists(rev_file):
        print(f'Database files already exist for commit {revision}')
        sys.exit(0)

    generate_versions_db(revision)


if __name__ == "__main__":
    main()
