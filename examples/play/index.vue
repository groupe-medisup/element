<template>
  <div style="margin: 20px;">
    <el-select
      @change="onChange"
      ref="select"
      allow-create
      :allow-create-label="value => `Ajouter ${value}`"
      default-first-option
      :filter-method="fetchSuggestions"
      clearable
      filterable
      loading-text="Chargement..."
      multiple
      :multiple-limit="1"
      no-data-text="Aucun élément"
      reserve-keyword
      size="small"
      tag-allow-close
      tag-label-key="currentValue"
      :tag-props="{
        color: '#FF00FF',
        borderColor: '#FF00FF',
        size: 'mini',
      }"
      :value="value"
    >
    <el-option
      v-for="val in optionsList"
      :key="val"
      :label="val"
      :value="val"
    />
  </el-select>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        value: [ 'une' ],
        options: [ 'une', 'deux', 'trois' ],
      };
    },
    computed: {
      optionsList () {
        return [  ...this.value, ...this.options ].filter((value, index, arr) => arr.indexOf(value) === index)
      }
    },
    methods: {
      onChange (value) {
        console.log('onChange', value)
        
        this.value = [ value ].flat()
      },
      fetchSuggestions () {
        return Promise.resolve([ 'quatre', 'cinq', 'six' ])
      },
    },
  };
</script>
