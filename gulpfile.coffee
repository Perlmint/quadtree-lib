gulp        = require 'gulp'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglify'
filter      = require 'gulp-filter'
sourcemaps  = require 'gulp-sourcemaps'
mocha       = require 'gulp-mocha'
istanbul    = require 'gulp-istanbul'
rename      = require 'gulp-rename'
docco       = require 'gulp-docco'
del         = require 'del'

paths =
    src:        ['src/**/*.coffee']
    demo:       ['demo/**/*', 'build/js/quadtree.min.js', 'build/js/quadtree.min.js.map']
    test:       ['test/*.coffee']
    perf:       ['test/perf/*.coffee']
    docindex:   ['docs/quadtree.html']

gulp.task 'clean', () ->
    del ['build', 'docs', 'coverage']

gulp.task 'build', () ->
    gulp.src paths.src
        .pipe sourcemaps.init()
        .pipe coffee bare: true
        .pipe sourcemaps.write '.'
        .pipe gulp.dest('build/js')
        .pipe(filter('**/*.js'))
        .pipe uglify()
        .pipe rename extname: '.min.js'
        .pipe sourcemaps.write '.'
        .pipe gulp.dest 'build/js'


gulp.task 'test', ['build'], () ->
    gulp.src 'build/js/quadtree.js'
        .pipe istanbul()
        .pipe istanbul.hookRequire()
        .on 'finish', ->
            gulp.src paths.test, read: false
            .pipe mocha reporter: 'nyan'
            .pipe istanbul.writeReports()

gulp.task 'perf', ['build'], () ->
    gulp.src paths.perf, read: false
        .pipe mocha reporter: 'spec'

gulp.task 'watch', () ->
    gulp.watch [paths.src, paths.test], ['build', 'test']

gulp.task 'generatedoc', () ->
    gulp.src paths.src
        .pipe docco layout: 'linear'
        .pipe gulp.dest './docs'

gulp.task 'setupdemo', () ->
    gulp.src paths.demo
        .pipe gulp.dest './docs/demo'

gulp.task 'doc', ['generatedoc', 'setupdemo'], () ->
    gulp.src paths.docindex
        .pipe rename 'index.html'
        .pipe gulp.dest './docs'

gulp.task 'default', ['test']
