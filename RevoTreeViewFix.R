treeView.httpd.handler <- function(path, query, ...) {
  path <- gsub("^/custom/RevoTreeView/", "", path)
  f <- sprintf("%s%s%s",
               tempdir(),
               .Platform$file.sep,
                 path)
  list(file=f,
       "content-type"="text/html",
       "status code"=200L)
}
 
plot.revoTreeView <- function(x, ...) {
    if(!tools:::httpdPort() > 0L) {
        tools:::startDynamicHelp()
    }
    env <- get( ".httpd.handlers.env", asNamespace("tools"))
    env[["RevoTreeView"]] <- treeView.httpd.handler
    root.dir <- paste(tempdir(),x$tempDir,sep="/")
 
#    template <- system.file("revolution", "index.html", package = "RevoTreeView")
    if ( ! file.exists(paste(root.dir,"assets", sep="/"))) { 
        tarFile <- system.file("revolution/build","assets.zip",package="RevoTreeView")
        unzip(tarFile,exdir=root.dir)
    }
    if ( ! file.exists(paste(root.dir,"tree.html", sep="/"))) {
        html.txt <- x$html
        html.txt <- gsub("\\{\\{DATA\\}\\}",x$json,html.txt)
        cat(html.txt, file=file.path(root.dir, paste("tree", ".html", sep="")))
    }
    file <- file.path(root.dir, paste("tree" ,".html", sep=""))
 
    .url <- sprintf("http://127.0.0.1:%s/custom/RevoTreeView/%s/%s",
                    tools:::httpdPort(),
                    x$tempDir,
                    basename(file))
    browseURL(.url)
    invisible(file)
}
