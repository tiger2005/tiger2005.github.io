import process from "node:process";

// 轻量终端进度条（仅在 TTY 中渲染）。
class SimpleProgressBar {
  constructor(label, total) {
    this.label = label;
    this.total = Math.max(1, total);
    this.current = 0;
    this.width = 28;
    this.start = Date.now();
    this.stream = process.stderr;
    this.isTTY = Boolean(this.stream && this.stream.isTTY);
  }

  tick(step = 1) {
    this.current = Math.min(this.total, this.current + step);
    this.render();
    if (this.current >= this.total) {
      this.finish();
    }
  }

  render() {
    if (!this.isTTY) {
      return;
    }

    const ratio = this.current / this.total;
    const filled = Math.round(this.width * ratio);
    const bar = `${"=".repeat(filled)}${" ".repeat(this.width - filled)}`;
    const percent = `${Math.round(ratio * 100)}%`.padStart(4, " ");

    const elapsedMs = Date.now() - this.start;
    const elapsedSec = elapsedMs / 1000;
    const remainingSec = this.current === 0
      ? 0
      : ((this.total - this.current) / this.current) * elapsedSec;

    const line = `${this.label} [${bar}] ${this.current}/${this.total} ${percent} ${remainingSec.toFixed(1)}s`;
    this.stream.write(`\r${line}`);
  }

  finish() {
    if (this.isTTY) {
      this.stream.write("\n");
    }
  }
}

// total<=0 时返回 null，调用方可直接跳过渲染。
export function createProgressBar(label, total) {
  if (!total || total <= 0) {
    return null;
  }

  return new SimpleProgressBar(label, total);
}
