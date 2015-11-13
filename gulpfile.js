'use strict';

var path = require('path');
var gulp = require('gulp');
var coffeelint = require('gulp-coffeelint');
var excludeGitignore = require('gulp-exclude-gitignore');
var nsp = require('gulp-nsp');

gulp.task('static', function() {
  return gulp.src('**/*.coffee')
    .pipe(excludeGitignore())
    .pipe(coffeelint())
    .pipe(coffeelint.reporter());
});

gulp.task('nsp', function(cb) {
  nsp({package: path.resolve('package.json')}, cb);
});

gulp.task('prepublish', ['nsp']);
gulp.task('default', ['static']);
