<template>
  <div id="app">
    <menu title="My app">
      <ul>
        <li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
      </ul>
      <div slot="footer">This is a footer slot menu.</div>
    </menu>
    <h1>{{ msg }}</h1>
  </div>
</template>

<script>
import Menu from './Menu.vue'

export default {
  components: {
    Menu
  },
  data () {
    return {
      // note: changing this line won't causes changes
      // with hot-reload because the reloaded component
      // preserves its current state and we are modifying
      // its initial state.
      msg: 'Hello, world! Hello, Vue!'
    }
  }
}
</script>

<style>
body {
  font-family: Helvetica, sans-serif;
}
</style>
