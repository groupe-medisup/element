<style lang="scss">
.page-container.page-theme-preview {
  padding-top: 30px;
  .display {
    width: 75%;
    display: inline-block;
    vertical-align: top;
    h3 {
      font-size: 28px;
      margin: 30px 0 0 0;
    }
  }
  .side {
    display: inline-block;
    width: 25%;
    .editor {
      overflow: hidden;
      background: #f5f7fa;
      border: 1px solid #ebeef5;
      border-radius: 5px;
      margin-bottom: 20px;
      &.fixed {
        position: fixed;
        width: 285px;
        box-sizing: border-box;
      }
    }
  }
}
</style>
<template>
  <div class="page-container page-theme-preview" ref="themePreview">
    <section class="display">
      <el-button type="text" icon="el-icon-back" @click="navBack">
        <%= 1 >
      </el-button>
      <h3>{{previewConfig.name}}</h3>
      <basic-tokens-preview>
      </basic-tokens-preview>
      <components-preview>
      </components-preview>
    </section>
  </div>
</template>
<script>
import ThemeConfigurator from '../../components/theme-configurator';
import ComponentsPreview from '../../components/theme/components-preview';
import BasicTokensPreview from '../../components/theme/basic-tokens-preview';
import {
  saveUserThemeToLocal
} from '../../components/theme/localstorage';
import throttle from 'throttle-debounce/throttle';
import { getActionDisplayName } from '../../components/theme-configurator/utils/utils';

const maxUserTheme = 8;

export default {
  components: {
    ThemeConfigurator,
    BasicTokensPreview,
    ComponentsPreview
  },
  data() {
    return {
      previewConfig: {},
      themeConfig: {},
      userTheme: [],
      editorTop: 0,
      editorHeight: 1000,
      isFixed: false
    };
  },
  computed: {
    isOfficial() {
      return this.previewConfig.type === 'official';
    }
  },
  created() {
    this.throttledHandleScroll = throttle(10, true, index => {
      this.handleScroll(index);
    });
  },
  methods: {
    navBack() {
      this.$router.go(-1);
      this.$nextTick(() => {
        window.scrollTo(0, 0);
      });
    },
    getNewUserThemeName(originName) {
      let n = 1;
      let name;
      while (true) {
        name = `${originName}-${n}`;
        if (this.userTheme.filter(theme => (theme.name === name)).length === 0) {
          break;
        }
        n += 1;
      }
      return name;
    },
    onUserConfigUpdate(userConfig) {
      const themeConfig = JSON.stringify(userConfig);
      const { type, name } = this.previewConfig;
      if (this.isOfficial) {
        if (this.userTheme.length >= maxUserTheme) {
          this.$message.error(getActionDisplayName('max-user-theme'));
          return;
        }
        const autoUserName = this.getNewUserThemeName(name);
        this.previewConfig.name = autoUserName;
        this.previewConfig.type = 'user';
        this.userTheme.push({
          update: Date.now(),
          name: autoUserName,
          theme: themeConfig
        });
        saveUserThemeToLocal(this.userTheme);
        return;
      }
      if (type === 'user') {
        this.userTheme.forEach((config) => {
          if (config.name === name) {
            config.update = Date.now();
            config.theme = themeConfig;
          }
        });
        saveUserThemeToLocal(this.userTheme);
      }
    },
    handleScroll() {
      const rect = this.$refs.themePreview.getBoundingClientRect();
      let offsetTop = rect.top;
      let offsetBottom = rect.bottom;
      const calHeight = this.editorHeight + 30 + 20;
      if (offsetTop < 0) {
        this.isFixed = true;
        if (offsetBottom < calHeight) {
          this.editorTop = 30 - calHeight + offsetBottom;
        } else {
          this.editorTop = 30;
        }
      } else {
        this.isFixed = false;
        this.editorTop = 0;
      }
    }
  },
  beforeDestroy() {
    window.removeEventListener('scroll', this.throttledHandleScroll);
  }
};
</script>
