require! \gulp
require! \gulp-exit
require! \gulp-livescript
require! \gulp-mocha
{instrument, hook-require, write-reports} = (require \gulp-live-istanbul)!
require! \gulp-nodemon
require! \livescript

gulp.task \server, ->
    gulp-nodemon do
        exec-map: ls: \lsc
        ext: \ls
        ignore: <[.gitignore gulpfile.ls notes spy-server.sublime-project README.md rough public/*]>
        script: \./server.ls
    
gulp.task \coverage, ->
    gulp.src <[routes.ls]>
    .pipe instrument!
    .pipe hook-require!

    gulp.src <[./test/index.ls]>
    .pipe gulp-mocha!
    .pipe write-reports!
    .on \finish, -> process.exit!

gulp.task \default, <[server]>