# ryannhg/application
> a way to build single page applications with Elm.

## Overview

Making single page applications in Elm is pretty great! You can create routes and match them up with different pages.

This project, `ryannhg/application` is an attempt to preserve the flexibility and simplicity of the Elm architecture, while rearranging things so you can more directly see the relationship between your routes and pages.

### Here's an example

```elm
module Main exposing (..)

import Application
import Pages.Home
import Pages.About
import Url.Parser as Parser

type Msg
  = HomeMsg Pages.Home.Msg
  | AboutMsg Pages.About.Msg

main : Application Flags Model Msg
main =
    Application.program
      { routes =
          [ Parser.map
              (Pages.Home.route HomeMsg)
              Parser.top
          , Parser.map
              (Pages.About.route AboutMsg)
              (Parser.s "about")
          ]
      }
```