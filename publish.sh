set -o errexit
set -o nounset
SOURCE=~/dev/groves.github.io
PAGES=~/dev/sevorg.org
cd $SOURCE
hugo --baseUrl https://sevorg.org/draft/ --destination $PAGES/draft/
#hugo --baseUrl https://sevorg.org/ --destination $PAGES
cd $PAGES
git add .
git commit -m publish
git push
