# This script  does the following
# 1. makes sure,it doesn't accidentally overwrite an existing image
# 2. adds git commit information into the image
# 3. adds git commit info into the image metadata

VERSION=1.5.0

if [ ! -z $1 ]
then
    VERSION=$1
fi

echo "building version $VERSION"

# login to hub.tess.io
docker login hub.tess.io


GIT_REPO=$(git remote get-url origin)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse HEAD)

echo "Git repository: $GIT_REPO"
echo "Git branch: $GIT_BRANCH"
echo "Git commit: $GIT_COMMIT"

GIT_INFO=$GIT_REPO:$GIT_BRANCH:$GIT_COMMIT
echo $GIT_INFO

docker build -t swift-downloader:$VERSION --label git-info=$GIT_INFO --build-arg git_commit=$GIT_INFO .

# TODO:  check whether the image exists in remote registry

docker tag swift-downloader:$VERSION hub.tess.io/pybay/swift-downloader:$VERSION

declare -a array=( "yes", "y", "Y" )
read -p "Push image to hub.tess.io: (Y/N)" deploy
if [[ " ${array[*]} " == *" ${deploy} "* ]]
then
    docker push hub.tess.io/pybay/swift-downloader:$VERSION
else
    echo 'Image NOT pushed'
fi


