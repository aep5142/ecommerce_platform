# List of repos to create
repos=("frontend-ecommerce" "products-ecommerce" "orders-ecommerce" "database-ecommerce")

STARTING_REPO=8001

# Creating repos
for repo in "${repos[@]}"; do
    
    # Creating the repos locally
    mkdir $repo || { echo "Directory $repo already exists, skipping"; continue; }
    echo "#Init Readme" > $repo/README.md
    cd "$repo" || { echo "Directory $repo not found, skipping"; continue; }
    
    # Creating common structure for each service
    mkdir templates src tests docs .github # Common structure
    echo '"""'"This is the $repo service"'"""' > src/main.py
    echo "# File Init" > Jenkinsfile # Creating Jenkinsfile
    echo "# File Init" > requirements.txt # # Creating requirements.txt
    echo "" > .gitignore # Creating gitignore
    cp ../setup_files/Dockerfile ./ # Creating Dockerfile from my local template
    cp ../setup_files/gitflow_branching.md docs/Branching_Strategy.md # This is the Branching Strategy Doc

    # Customizing the Dockerfile
    echo "# Port which will be exposed
EXPOSE $STARTING_REPO

# Running the container (Using uvicorn to have a web server for my FastAPi object in main.py)
CMD [\"uvicorn\", \"app.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"$STARTING_REPO\"]" >> Dockerfile
    
    # Modifying the Repo Expose
    ((STARTING_REPO += 1))

    # Going back to the root to keep working
    cd ..

    # End of for loop 
    done