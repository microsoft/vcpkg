#!/usr/bin/env node
import * as fs from "fs";
import * as path from "path";

const include_subpath = "/include/";

function getFiles(dirPath: string): string[] {
  const files = fs.readdirSync(dirPath);
  return files.filter((f) => !f.startsWith("."));
}

function genAllFileStrings(
  dirPath: string,
  files: string[],
  headersStream: fs.WriteStream,
  outputStream: fs.WriteStream
) {
  for (const file of files) {
    const components = file.split("_");
    const pkg = components[0] + ":" + components[2].replace(".list", "");
    const content = fs.readFileSync(path.join(dirPath, file), "utf8");
    const lines = content.split(/\r?\n/);
    for (const raw of lines) {
      if (!raw) continue;
      const line = raw.trim();
      if (line.length === 0) continue;
      if (line.endsWith("/")) continue;
      // Remove the leading triplet directory
      const idx = line.indexOf("/");
      const filepath = idx >= 0 ? line.substring(idx) : line;
      outputStream.write(pkg + ":" + filepath + "\n");
      if (filepath.startsWith(include_subpath)) {
        headersStream.write(pkg + ":" + filepath.substring(include_subpath.length) + "\n");
      }
    }
  }
}

function usage() {
  console.error("Usage: file_script.ts --info-dir <path-to-info-dir> [--out-dir <path>]");
}

function parseArgs(argv: string[]) {
  let infoDir: string | undefined;
  let outDir = "scripts/list_files";
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--info-dir") {
      i++;
      infoDir = argv[i];
    } else if (a === "--out-dir") {
      i++;
      outDir = argv[i];
    } else if (a.startsWith("--")) {
      console.error(`Unknown argument: ${a}`);
      usage();
      process.exit(2);
    } else {
      console.error(`Unexpected positional argument: ${a}`);
      usage();
      process.exit(2);
    }
  }
  if (!infoDir) {
    console.error("info-dir is required");
    usage();
    process.exit(2);
  }
  return { infoDir, outDir };
}

function main() {
  const { infoDir: dir, outDir } = parseArgs(process.argv.slice(2));
  try {
    fs.mkdirSync(outDir, { recursive: true });
  } catch {
    // ignore
  }

  const headersPath = path.join(outDir, "VCPKGHeadersDatabase.txt");
  const dbPath = path.join(outDir, "VCPKGDatabase.txt");
  const headers = fs.createWriteStream(headersPath, { encoding: "utf8" });
  const output = fs.createWriteStream(dbPath, { encoding: "utf8" });
  try {
    const files = getFiles(dir);
    genAllFileStrings(dir, files, headers, output);
  } finally {
    headers.end();
    output.end();
  }
}

main();
