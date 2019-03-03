import { Elm } from './src/Main.elm'

const node = document.getElementById('app')

if (node) {
  Elm.Main.init({ node })
}
