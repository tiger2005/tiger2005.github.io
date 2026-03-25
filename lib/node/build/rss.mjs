import { existsSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";
import { ROOT_DIR } from "./constants.mjs";
import { ensureDirForFile, normalizePosixPath, safeRead, upsertStatus } from "./helpers.mjs";

const DEFAULT_RSS_SITE_TITLE = "Carbon Typst Blog";
const DEFAULT_RSS_SITE_URL = "https://example.com";
const DEFAULT_RSS_DESCRIPTION = "Carbon Typst Blog RSS Feed";
const DEFAULT_RSS_LANGUAGE = "zh-cn";
export const SITE_CONFIG_FILE_NAME = "site.config.json";

// 转义 XML 文本节点/属性值。
function escapeXml(value) {
  return String(value || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

// 从外置 JSON 读取站点信息；未配置字段走默认值。
function readSiteInfoFromExternalConfig(siteConfigPath) {
  const raw = safeRead(siteConfigPath).trim();
  if (!raw) {
    return {
      siteTitle: DEFAULT_RSS_SITE_TITLE,
      siteUrl: DEFAULT_RSS_SITE_URL,
      description: DEFAULT_RSS_DESCRIPTION,
      language: DEFAULT_RSS_LANGUAGE,
    };
  }

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    throw new Error(`Invalid JSON in ${normalizePosixPath(relative(ROOT_DIR, siteConfigPath))}`);
  }

  return {
    siteTitle: String(parsed.siteTitle || DEFAULT_RSS_SITE_TITLE).trim(),
    siteUrl: String(parsed.siteUrl || DEFAULT_RSS_SITE_URL).trim().replace(/\/+$/, ""),
    description: String(parsed.description || DEFAULT_RSS_DESCRIPTION).trim(),
    language: String(parsed.language || DEFAULT_RSS_LANGUAGE).trim(),
  };
}

// 组装绝对链接（用于 RSS item/link/guid）。
function joinSiteUrl(siteUrl, path) {
  const cleanPath = `/${String(path || "").replace(/^\/+/, "")}`;
  return `${siteUrl}${cleanPath}`;
}

// 将日期文本转换为 RSS 要求的 RFC 2822 格式。
function toRssDate(dateText, fallbackIso) {
  const parsed = new Date(dateText || fallbackIso || Date.now());
  if (Number.isNaN(parsed.getTime())) {
    return new Date().toUTCString();
  }
  return parsed.toUTCString();
}

// 根据 posts metadata 生成 RSS XML 字符串。
function buildRssXml(posts, siteInfo) {
  const sortedPosts = [...posts].sort((a, b) => {
    const ta = new Date(a.date || a.lastModified || 0).getTime();
    const tb = new Date(b.date || b.lastModified || 0).getTime();
    if (ta !== tb) {
      return tb - ta;
    }
    return String(a.slug).localeCompare(String(b.slug));
  });

  const latest = sortedPosts[0];
  const channelLink = joinSiteUrl(siteInfo.siteUrl, "/");
  const channelDescription = siteInfo.description || `${siteInfo.siteTitle} RSS Feed`;
  const lastBuildDate = latest
    ? toRssDate(latest.date, latest.lastModified)
    : new Date().toUTCString();

  const items = sortedPosts.map((post) => {
    const link = joinSiteUrl(siteInfo.siteUrl, post.url || `/${post.slug}/`);
    const title = escapeXml(post.title || post.slug || "Untitled");
    const description = escapeXml(post.description || "");
    const pubDate = toRssDate(post.date, post.lastModified);
    const tags = Array.isArray(post.tags) ? Array.from(new Set(post.tags.filter(Boolean))) : [];
    const categoryNodes = [
      post.category
        ? `    <category domain="category">${escapeXml(post.category)}</category>`
        : "",
      ...tags.map((tag) => `    <category domain="tag">${escapeXml(tag)}</category>`),
    ]
      .filter(Boolean)
      .join("\n");

    return [
      "  <item>",
      `    <title>${title}</title>`,
      `    <link>${escapeXml(link)}</link>`,
      `    <guid isPermaLink=\"true\">${escapeXml(link)}</guid>`,
      `    <pubDate>${escapeXml(pubDate)}</pubDate>`,
      `    <description>${description}</description>`,
      categoryNodes,
      "  </item>",
    ].filter(Boolean).join("\n");
  }).join("\n");

  return [
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
    "<rss version=\"2.0\">",
    "<channel>",
    `  <title>${escapeXml(siteInfo.siteTitle)}</title>`,
    `  <link>${escapeXml(channelLink)}</link>`,
    `  <description>${escapeXml(channelDescription)}</description>`,
    `  <language>${escapeXml(siteInfo.language || DEFAULT_RSS_LANGUAGE)}</language>`,
    `  <lastBuildDate>${escapeXml(lastBuildDate)}</lastBuildDate>`,
    items,
    "</channel>",
    "</rss>",
    "",
  ].join("\n");
}

// 生成 rss.xml 到 staging，并纳入 updated/unchanged 统计。
export function stageRss(posts, outputSiteDir, stagingSiteDir, siteConfigPath, statusMap) {
  const siteInfo = readSiteInfoFromExternalConfig(siteConfigPath);
  const rssXml = buildRssXml(posts, siteInfo);
  const outputRel = "rss.xml";
  const oldOutputPath = join(outputSiteDir, outputRel);
  const stagingPath = join(stagingSiteDir, outputRel);

  ensureDirForFile(stagingPath);
  const unchanged = existsSync(oldOutputPath) && safeRead(oldOutputPath) === rssXml;
  writeFileSync(stagingPath, rssXml, "utf8");
  upsertStatus(statusMap, outputRel, unchanged ? "unchanged" : "updated");
}
