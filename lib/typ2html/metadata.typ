#import "sys-input.typ": query-input

#let normalize-url(base, path) = {
  let clean-base = str(base).trim("/", at: end)
  let clean-path = str(path).trim("/")
  if clean-path == "" {
    clean-base + "/"
  } else {
    clean-base + "/" + clean-path + "/"
  }
}

#let seo-tags(
  title: "",
  author: none,
  description: none,
  canonical-url: none,
  page-path: none,
) = {
  let clean-page-path = if page-path == none { "" } else { str(page-path).trim("/") }
  let og-type = if clean-page-path == "" { "website" } else { "article" }

  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: og-type))

  if description != none and str(description) != "" {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  if canonical-url != none and str(canonical-url) != "" {
    html.elem("meta", attrs: (property: "og:url", content: canonical-url))
  }

  if author != none and str(author) != "" {
    html.meta(name: "author", content: author)
    if og-type == "article" {
      html.elem("meta", attrs: (property: "article:author", content: author))
    }
  }

  html.meta(name: "twitter:card", content: "summary")
}

#let metadata(
  title: "",
  author: query-input("author", default: none),
  description: none,
  lang: "zh",
  date: none,
  website-title: "",
  website-url: none,
  canonical-path: none,
  include-rss-link: false,
  feed-path: "/rss.xml",
) = {
  html.meta(charset: "utf-8")
  html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
  html.meta(name: "color-scheme", content: "light dark")
  html.meta(name: "generator", content: "Typst")

  let page-title = if title != "" {
    title
  } else if website-title != "" {
    website-title
  } else {
    "Untitled Page"
  }
  html.title(page-title)

  if type(date) == datetime {
    html.meta(name: "date", content: date.display("[year]-[month]-[day]"))
  } else if type(date) == str and date != "" {
    html.meta(name: "date", content: date)
  }

  if include-rss-link {
    let rss-title = if website-title != "" { website-title } else { page-title }
    html.link(
      rel: "alternate",
      type: "application/rss+xml",
      href: feed-path,
      title: rss-title + " RSS Feed",
    )
  }

  let resolved-page-path = if canonical-path != none {
    str(canonical-path)
  } else {
    str(query-input("page-path", default: ""))
  }

  let canonical-url = if website-url != none and str(website-url) != "" {
    normalize-url(website-url, resolved-page-path)
  } else {
    none
  }

  if canonical-url != none {
    html.link(rel: "canonical", href: canonical-url)
  }

  seo-tags(
    title: page-title,
    author: author,
    description: description,
    page-path: resolved-page-path,
    canonical-url: canonical-url,
  )

  if lang != "" {
    html.meta(name: "language", content: lang)
  }
}
