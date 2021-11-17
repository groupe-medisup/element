<template>
  <div>
    <table @click="handleYearTableClick" class="el-year-table">
      <tbody>
      <tr v-for="(row, key) in rows" :key="key">
        <td v-for="(cell, key) in row" :key="key" :class="getCellStyle(cell)">
          <a class="cell">{{ cell.text }}</a>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<script type="text/babel">
  import { hasClass } from 'element-ui/src/utils/dom';
  import { isDate, range, nextDate, getDayCountOfYear } from 'element-ui/src/utils/date-util';
  import { arrayFind, arrayFindIndex, coerceTruthyValueToArray } from 'element-ui/src/utils/util';

  const datesInYear = year => {
    const numOfDays = getDayCountOfYear(year);
    const firstDay = new Date(year, 0, 1);
    return range(numOfDays).map(n => nextDate(firstDay, n));
  };

  const removeFromArray = function(arr, pred) {
    const idx = typeof pred === 'function' ? arrayFindIndex(arr, pred) : arr.indexOf(pred);
    return idx >= 0 ? [...arr.slice(0, idx), ...arr.slice(idx + 1)] : arr;
  };

  export default {
    props: {
      disabledDate: {},
      value: {},
      defaultValue: {
        validator(val) {
          // null or valid Date Object
          return val === null || (val instanceof Date && isDate(val));
        }
      },
      date: {},
      selectionMode: {
        default: 'schoolyear'
      }
    },

    computed: {
      startYear() {
        return Math.floor(this.date.getFullYear() / 10) * 10;
      },
      rows() {
        const r = [];
        const nbRows = 3;
        const nbCols = 4;
        const startYear = this.startYear;
        const disabledDate = this.disabledDate;
        const cellClassName = this.cellClassName;
        const selectedDate = [ 'dates', 'schoolyears' ].includes(this.selectionMode)
          ? coerceTruthyValueToArray(this.value)
          : [];

        for (let i = 0; i < nbRows; i++) {
          const row = [];

          for (let j = 0; j < nbCols && i * nbCols + j < 10; j++) {
            const y = startYear + i * nbCols + j;
            const cellDate = new Date(y, 0);

            const cell = {
              year: y,
              text: y + '-' + (y + 1),
              disabled: typeof disabledDate === 'function' && disabledDate(cellDate),
              selected: arrayFind(selectedDate, date => date.getUTCFullYear() === cellDate.getUTCFullYear()),
              customClass: typeof cellClassName === 'function' && cellClassName(cellDate)
            };

            row.push(cell);
          }
          r.push(row);
        }
        return r;
      }
    },

    methods: {
      getCellStyle(cell) {
        const style = {};
        const today = new Date();

        style.disabled = typeof this.disabledDate === 'function'
          ? datesInYear(cell.year).every(this.disabledDate)
          : false;
        style.current = arrayFindIndex(coerceTruthyValueToArray(this.value), date => date.getFullYear() === cell.year) >= 0;
        style.today = today.getFullYear() === cell.year;
        style.default = this.defaultValue && this.defaultValue.getFullYear() === cell.year;
        style.active = cell.selected;

        return style;
      },

      handleYearTableClick(event) {
        const target = event.target;
        if (target.tagName === 'A') {
          if (hasClass(target.parentNode, 'disabled')) return;
          const schoolYear = target.textContent || target.innerText;
          const year = schoolYear.split('-')[0];
          const newDate = new Date(year, 0);
          if (this.selectionMode === 'schoolyears') {
            const row = target.parentNode.parentNode.rowIndex;
            const column = target.parentNode.cellIndex;
            const cell = this.rows[row][column];
            const value = this.value || [];
            const newValue = cell.selected
              ? removeFromArray(value, date => date.getTime() === newDate.getTime())
              : [...value, newDate];
            this.$emit('pick', newValue);
          } else {
            const schoolYear = target.textContent || target.innerText;
            const year = schoolYear.split('-')[0];
            this.$emit('pick', Number(year));
          }
        }
      }
    }
  };
</script>
