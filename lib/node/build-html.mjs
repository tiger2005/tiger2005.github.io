#!/usr/bin/env node

import { rmSync } from "node:fs";
import { resolve } from "node:path";
import process from "node:process";
import { ROOT_DIR } from "./build/constants.mjs";
import { parseArgs } from "./build/cli.mjs";
import { buildSite } from "./build/core.mjs";

let options = null;

try {
  // 解析 CLI 参数并执行完整构建流程
  options = parseArgs();
  await buildSite(options);
} catch (error) {
  console.error("Build failed");
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
} finally {
  // 清理缓存目录，避免残留临时文件
  const cacheRoot = options?.cacheRoot || ".typ-blog-cache";
  rmSync(resolve(ROOT_DIR, cacheRoot), { recursive: true, force: true });
}
