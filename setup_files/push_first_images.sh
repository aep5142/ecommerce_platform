# Array of repos
# List of repos to create
repos=("frontend-ecommerce" "products-ecommerce" "orders-ecommerce" "database-ecommerce")
docker_username=aeyzaguirre

for repo in "${repos[@]}"; do

    # Going to the repo folder
    cd "$repo" || { echo "Directory $repo not found, skipping"; continue; }

    # Building the image
    docker build -t $docker_username/$repo:v1.0 .
    docker tag $docker_username/$repo:v1.0 $docker_username/$repo:latest


    # Pushing th image
    docker push $docker_username/$repo:v1.0
    docker push $docker_username/$repo:latest

    # Going back to the root
    cd ..

done