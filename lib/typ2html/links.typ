#import "html-guard.typ": html-guard

#let template-links(content) = {
  let is-relative-link(dest) = {
    dest.starts-with("/") or dest.starts-with("./") or dest.starts-with("../") or dest.starts-with("#") or dest.starts-with("?")
  }

  show link: it => {
    if type(it.dest) == str {
      if not is-relative-link(it.dest) {
        html-guard(
          () => html.a(
            href: it.dest,
            target: "_blank",
            rel: ("noopener", "noreferrer"),
            it.body,
          ),
          fallback: () => it,
        )
      } else {
        it
      }
    } else {
      it
    }
  }
  
  content
}
