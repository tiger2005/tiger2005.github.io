#let query-input(key, default: none) = sys.inputs.at(key, default: default)

#let query-posts() = {
  let posts-json-path = query-input("posts-json", default: none)
  if posts-json-path == none { () } else { json(posts-json-path) }
}

#let query-slugs() = {
  let slugs-json-path = query-input("slugs-json", default: none)
  if slugs-json-path == none { (:) } else { json(slugs-json-path) }
}

#let query-route-tag(default: "") = str(query-input("route-tag", default: default))

#let query-route-category(default: "") = str(query-input("route-category", default: default))

#let query-route-page(default: 1) = {
  let raw = str(query-input("route-page", default: str(default)))
  calc.max(1, int(raw))
}

#let query-route-page-size(default: 10) = {
  let raw = str(query-input("route-page-size", default: str(default)))
  calc.max(1, int(raw))
}

#let query-tag-slug-of(value) = {
  let tag-slugs = query-slugs().at("tags", default: (:))
  str(tag-slugs.at(value, default: value))
}

#let query-category-slug-of(value) = {
  let category-slugs = query-slugs().at("categories", default: (:))
  str(category-slugs.at(value, default: value))
}

#let query-page-bounds(total, page: 1, page-size: 10) = {
  let size = calc.max(1, int(page-size))
  let pages = if total <= 0 {
    1
  } else {
    int(calc.ceil(total / size))
  }

  let current = calc.min(calc.max(1, int(page)), pages)

  if total <= 0 {
    (
      page: current,
      page-size: size,
      total-pages: pages,
      start-index: 0,
      end-index: -1,
    )
  } else {
    let end-index = total - (current - 1) * size - 1
    let start-index = calc.max(0, end-index - size + 1)
    (
      page: current,
      page-size: size,
      total-pages: pages,
      start-index: start-index,
      end-index: end-index,
    )
  }
}
