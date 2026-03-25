#import "@preview/theorion:0.4.1": *
#import "html-guard.typ": html-guard

#let quote(body) = context {
  html-guard(() => {
    html.div(class: "quote-block", {
      body
    })
  }, fallback: () => quote-box(body))
}

#let block-title(title) = {
  if title != none {
    html.div(class: "block-title", title)
  }
}

#let note(title: none, body) = context {
  html-guard(() => {
    html.div(class: "note-block", {
      block-title(title)
      body
    })
  }, fallback: () => {
    if title == none {
      note-box(body)
    } else {
      note-box(title: title, icon-name: "info", body)
    }
  })
}

#let success(title: none, body) = context {
  html-guard(() => {
    html.div(class: "success-block", {
      block-title(title)
      body
    })
  }, fallback: () => {
    if title == none {
      tip-box(body)
    } else {
      tip-box(title: title, icon-name: "check-circle-fill", body)
    }
  })
}

#let warning(title: none, body) = context {
  html-guard(() => {
    html.div(class: "warning-block", {
      block-title(title)
      body
    })
  }, fallback: () => {
    if title == none {
      warning-box(body)
    } else {
      warning-box(title: title, icon-name: "alert-fill", body)
    }
  })
}


#let error(title: none, body) = context {
  html-guard(() => {
    html.div(class: "error-block", {
      block-title(title)
      body
    })
  }, fallback: () => {
    if title == none {
      caution-box(body)
    } else {
      caution-box(title: title, icon-name: "circle-slash", body)
    }
  })
}
