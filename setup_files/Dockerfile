# Using latest version of Python
FROM python 3:13

# Setting up the Working Directory
WORKDIR app/

# Copying and running the requirements
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Doing the setup of copy the source code to be run
COPY src/ ./

