'use strict';

const { series, src, dest } = require('gulp');
const sass = require('gulp-dart-sass');
const autoprefixer = require('gulp-autoprefixer');
const cssmin = require('gulp-cssmin');
const map = require('map-stream');
const { Buffer } = require('node:buffer');

const VAR_RE = /\/\/\/VAR (\@import\s["'][\w\.\/\-]+["'];)/i;

function compile() {
  return src('./src/*.scss')
    .pipe(map(function(file, cb) {
      if (file.isNull()) {
        return cb(null, file);
      }

      let contents = Buffer.from(file.contents, 'utf-8').toString('utf-8');
      const importsVars = VAR_RE.exec(contents.slice(0, 1024));

      if (Array.isArray(importsVars) && importsVars.length && importsVars[1]) {
        contents = contents.replace(VAR_RE, importsVars[1]);
        file.contents = Buffer.from(contents, 'utf8');
      }

      cb(null, file);
    }))
    .pipe(sass.sync().on('error', sass.logError))
    .pipe(autoprefixer({
      overrideBrowserslist: ['ie > 9', 'last 2 versions'],
      cascade: false
    }))
    .pipe(cssmin())
    .pipe(dest('./lib'));
}

function copyfont() {
  return src('./src/fonts/**')
    .pipe(cssmin())
    .pipe(dest('./lib/fonts'));
}

exports.build = series(compile, copyfont);
