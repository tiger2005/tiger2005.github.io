#import "html-guard.typ": html-guard

#let divider() = {
  html-guard(
    () => html.hr(),
    fallback: () => line(length: 100%, stroke: gray),
  )
}
