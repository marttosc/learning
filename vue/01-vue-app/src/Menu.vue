<template>
    <h4>{{title}}</h4>
    <div>
      <slot></slot>
    </div>
    <hr>
    <slot name="footer"></slot>
</template>

<script>
    export default {
      props: ['title']
    }
</script>
