# List of repos to create
repos=("frontend-ecommerce" "products-ecommerce" "orders-ecommerce" "database-ecommerce")

# My username
GH_USERNAME="aep5142"

# Creating repos
for repo in "${repos[@]}"; do
    
    # Going to the repo folder
    cd "$repo" || { echo "Directory $repo not found, skipping"; continue; }
     
    #Start git
    git init

    #Adding files
    git add .
    git commit -m "Init Repo"
    gh repo create $repo --private --source=. --push
    
    # Creating the develop branch and pushing it
    git switch -c develop
    git push -u origin develop
    
    # Protecting the main and develop branches

    branches_protection=("main" "develop")

    for branch in "${branches_protection[@]}"; do

        gh api --method PUT \
            "repos/$GH_USERNAME/$repo/branches/$branch/protection" \
            --input - <<EOF
    {
    "required_status_checks": null,
    "enforce_admins": true,
    "required_pull_request_reviews": {
        "required_approving_review_count": 1
    },
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false
    }
EOF
    done

    # Going back to the root to keep working
    cd ..

    # End of for loop 
done


## Creating the orchestrating repo
orch_repo="99_orchestrating_repo"

# Going to the repo
cd $orch_repo

#Initializing
git init

# Adding file
git add .
git commit -m"Setup files"

# Creating the repo
gh repo create ecommerce_platform --private --source=. --push

# Going back to the root
cd ..
