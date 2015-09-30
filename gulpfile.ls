require! \gulp
require! \gulp-livescript
require! \gulp-nodemon
 
gulp.task \build, ->
    gulp.src <[routes.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './'

gulp.task \watch, ->
    gulp.watch <[./routes.ls]>, <[build]>

gulp.task \server, ->
    gulp-nodemon do
        exec-map: ls: \lsc
        ext: \ls
        ignore: <[.gitignore gulpfile.ls notes spy-server.sublime-project README.md rough public/*]>
        script: \./server.ls
    
gulp.task \default, <[build watch server]>