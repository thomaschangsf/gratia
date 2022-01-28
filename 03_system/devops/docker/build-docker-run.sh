APP=$1                      # swift-downloader
VERSION=$2                  # 1.6.1
REMOTE_REPO_HOST=$3         # hub.tess.io
REMOTE_REPO_PROJECT=$4      # pybay

if [ -z "$REMOTE_REPO_HOST" ]
then
    REMOTE_REPO_HOST=hub.tess.io
fi

if [ -z "$REMOTE_REPO_PROJECT" ]
then
    REMOTE_REPO_PROJECT=pybay
fi

# cd to directory containing Dockerfile

LOCAL_IMAGE=$APP:$VERSION
echo "LOCAL_IMAGE=$LOCAL_IMAGE"

docker build -t $LOCAL_IMAGE  .


declare -a yes=( "yes", "y", "Y" )

read -p "Test locally: (Y/N)" test_locally
if [[ " ${yes[*]} " == *" ${test_locally} "* ]]
then
  echo "sudo docker run -it -d --env-file env-list.txt $LOCAL_IMAGE sleep 36000"
  echo "sudo docker run -it -d --env-file env-list.txt $LOCAL_IMAGE bash"
else
    echo 'Skip testing locally'
fi


read -p "Push image to $REMOTE_REPO_HOST: (Y/N)" push_image
if [[ " ${yes[*]} " == *" ${push_image} "* ]]
then
  REMOTE_IMAGE=$REMOTE_REPO_HOST/$REMOTE_REPO_PROJECT/$APP:$VERSION
  echo "REMOTE_IMAGE=$REMOTE_IMAGE"
  docker tag $LOCAL_IMAGE $REMOTE_IMAGE
  echo "Login to remote repo"
  sudo docker login $REMOTE_REPO_HOST
  sudo docker push $REMOTE_IMAGE
else
    echo 'Image NOT pushed'
fi