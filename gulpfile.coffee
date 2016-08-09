path = require 'path'
gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'
excludeGitignore = require 'gulp-exclude-gitignore'
nsp = require 'gulp-nsp'

gulp.task 'static', () ->
  gulp.src '**/*.coffee'
    .pipe excludeGitignore()
    .pipe coffeelint()
    .pipe coffeelint.reporter()
    .pipe coffeelint.reporter('fail')

gulp.task 'nsp', (cb) ->
  nsp { package: path.resolve('package.json') }, cb

gulp.task 'default', ['static']
