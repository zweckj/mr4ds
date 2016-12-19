FILES=../Student-Resources/rmarkdown/*.Rmd
for f in $FILES
do
    ipyrmd --from Rmd --to ipynb $f -o "${f%.Rmd}.ipynb" -y
    mv ../Student-Resources/rmarkdown/*.ipynb ../Student-Resources/notebooks/
done


