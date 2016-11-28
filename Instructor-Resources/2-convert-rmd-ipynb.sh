FILES=../Student-Resources/rmarkdown/*.Rmd
for f in $FILES
do
    ipyrmd --from Rmd --to ipynb $f
done


