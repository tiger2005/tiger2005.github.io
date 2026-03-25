// 生产配置：每页 10 篇文章。
export const POSTS_PER_PAGE = 10;

// 计算总页数，至少返回 1。
export function calcTotalPages(totalItems, pageSize = POSTS_PER_PAGE) {
  const total = Math.max(0, Number(totalItems) || 0);
  const size = Math.max(1, Number(pageSize) || 1);
  return Math.max(1, Math.ceil(total / size));
}

// 仅第一页保持原地址，后续页追加 /page/<n>/。
export function withPagePath(basePath, page) {
  const normalizedBase = String(basePath || "").replace(/^\/+|\/+$/g, "");
  const pageNumber = Math.max(1, Number(page) || 1);

  if (pageNumber <= 1) {
    return normalizedBase;
  }

  if (normalizedBase === "") {
    return `page/${pageNumber}`;
  }

  return `${normalizedBase}/page/${pageNumber}`;
}

// 生成 [1..totalPages] 的页码列表。
export function listPages(totalPages) {
  const total = Math.max(1, Number(totalPages) || 1);
  return Array.from({ length: total }, (_, index) => index + 1);
}