import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// 统一定义构建脚本使用的仓库基础路径
export const ROOT_DIR = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..", "..");
export const POSTS_DIR = join(ROOT_DIR, "posts");
export const PAGES_DIR = join(ROOT_DIR, "pages");
export const ASSETS_DIR = join(ROOT_DIR, "assets");
export const TYPE_TOOLCHAIN_DIR = join(ROOT_DIR, "lib", "typ2html");
