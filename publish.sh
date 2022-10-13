set -o errexit
set -o nounset
SOURCE=~/dev/groves.github.io
PAGES=~/dev/sevorg.org
cd $SOURCE
for f in content/posts/* ; do 
  aspell check --dont-backup $f
done
hugo --buildDrafts --baseUrl https://sevorg.org/draft/ --destination $PAGES/draft/
HUGO_ENV=production hugo --baseUrl https://sevorg.org/ --destination $PAGES
cd $PAGES
git add .
git commit -m publish
git push
