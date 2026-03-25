// 通用并发池：限制并发执行 worker，并按原顺序返回结果。
export async function runPool(items, concurrency, worker, progressBar = null) {
  if (items.length === 0) {
    return [];
  }

  const result = new Array(items.length);
  let cursor = 0;
  const limit = Math.max(1, concurrency);

  async function consume() {
    while (true) {
      const index = cursor;
      cursor += 1;
      if (index >= items.length) {
        return;
      }

      result[index] = await worker(items[index], index);
      if (progressBar) {
        progressBar.tick();
      }
    }
  }

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => consume()));
  return result;
}
